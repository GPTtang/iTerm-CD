#!/usr/bin/env python3
"""生成 cd to iTerm2.workflow，避免 XML 手写的编码问题。"""

import plistlib
import os
import uuid
import shutil

SERVICES_DIR = os.path.expanduser("~/Library/Services")
WORKFLOW_NAME = "cd to iTerm2"
WORKFLOW_PATH = os.path.join(SERVICES_DIR, f"{WORKFLOW_NAME}.workflow")
CONTENTS_PATH = os.path.join(WORKFLOW_PATH, "Contents")

# ── Shell script（传给 Run Shell Script action）────────────────────────────────
# 用单个 osascript 调用 + 多行 AppleScript，避免多 -e 和 & 转义问题
SHELL_SCRIPT = r"""for f in "$@"; do
  if [ -d "$f" ]; then
    DIR="$f"
  else
    DIR=$(dirname "$f")
  fi
  open -a iTerm "$DIR"
done
"""

# ── document.wflow plist ──────────────────────────────────────────────────────
action_uuid = str(uuid.uuid4()).upper()

document = {
    "AMApplicationBuild": "523",
    "AMApplicationVersion": "2.10",
    "AMDocumentSpecVersion": "0.9",
    "AMWorkflowCategory": "AMAcceptFilesCategory",
    "actions": [
        {
            "action": {
                "AMAccepts": {
                    "Container": "List",
                    "Optional": True,
                    "Types": ["com.apple.cocoa.path"],
                },
                "AMActionVersion": "2.0.3",
                "AMApplication": ["Automator"],
                "AMParameterProperties": {
                    "COMMAND_STRING": {},
                    "CheckedForUserDefaultShell": {},
                    "inputMethod": {},
                    "shell": {},
                    "source": {},
                },
                "AMProvides": {
                    "Container": "List",
                    "Types": ["com.apple.cocoa.path"],
                },
                "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
                "ActionName": "Run Shell Script",
                "ActionParameters": {
                    "COMMAND_STRING": SHELL_SCRIPT,
                    "CheckedForUserDefaultShell": True,
                    "inputMethod": 1,   # pass as arguments
                    "shell": "/bin/bash",
                    "source": "",
                },
                "BundleIdentifier": "com.apple.RunShellScript",
                "CFBundleVersion": "2.0.3",
                "CanShowSelectedItemsWhenRun": False,
                "CanShowWhenRun": True,
                "Category": ["AMCategoryUtilities"],
                "Class Name": "RunShellScriptAction",
                "InputUUID": str(uuid.uuid4()).upper(),
                "OutputUUID": str(uuid.uuid4()).upper(),
                "UUID": action_uuid,
                "UnlocalizedApplications": ["Automator"],
                "arguments": {
                    "0": {"default value": 0,  "name": "inputMethod",    "required": "0", "type": "0", "uuid": "0"},
                    "1": {"default value": "", "name": "COMMAND_STRING",  "required": "0", "type": "0", "uuid": "1"},
                    "2": {"default value": "/bin/sh", "name": "shell",   "required": "0", "type": "0", "uuid": "2"},
                },
                "isViewVisible": 1,
                "location": "398.500000:253.000000",
                "nibPath": "/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib",
            },
            "isViewVisible": 1,
        }
    ],
    "connectors": {},
    "workflowMetaData": {
        "applicationBundleIDsByPath": {},
        "applicationPaths": [],
        "inputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "outputTypeIdentifier": "com.apple.Automator.nothing",
        "presentationMode": 11,
        "processesInput": 1,
        "serviceApplicationBundleID": "com.apple.finder",
        "serviceApplicationPath": "/System/Library/CoreServices/Finder.app",
        "serviceInputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceProcessesInput": 1,
        "systemImageName": "NSTerminal",
        "useAutomaticInputType": 0,
        "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
    },
}

# ── Info.plist ────────────────────────────────────────────────────────────────
info = {
    "NSServices": [
        {
            "NSMenuItem": {"default": WORKFLOW_NAME},
            "NSMessage": "runWorkflowAsService",
            "NSRequiredContext": {"NSApplicationIdentifier": "com.apple.finder"},
            "NSSendFileTypes": ["public.folder", "public.item"],
        }
    ]
}

# ── Write files ───────────────────────────────────────────────────────────────
if os.path.exists(WORKFLOW_PATH):
    shutil.rmtree(WORKFLOW_PATH)

os.makedirs(CONTENTS_PATH)

with open(os.path.join(CONTENTS_PATH, "document.wflow"), "wb") as f:
    plistlib.dump(document, f, fmt=plistlib.FMT_XML)

with open(os.path.join(CONTENTS_PATH, "Info.plist"), "wb") as f:
    plistlib.dump(info, f, fmt=plistlib.FMT_XML)

print(f"✅  workflow 已生成: {WORKFLOW_PATH}")
