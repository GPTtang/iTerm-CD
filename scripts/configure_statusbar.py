#!/usr/bin/env python3
"""
configure_statusbar.py — 直接修改 iTerm2 plist，启用状态栏并添加 cd-to 组件。
用法: python3 configure_statusbar.py <plist_path>
"""

import plistlib
import sys
import os
import shutil

COMPONENT_ID = "io.github.iterm-cd.cd-to-current"

COMPONENT_ENTRY = {
    "class": "iTermStatusBarRPCComponent",
    "configuration": {
        "iTermStatusBarComponentIdentifier": COMPONENT_ID,
        "knobs": {},
        "layout advanced configuration dictionary value": {
            "algorithm": 0,
            "auto-rainbow style": 0,
            "priority": 5,
            "font": {
                "family": "",
                "member": "",
                "pointSize": 0.0,
                "style": "",
            },
        },
    },
}


def configure(plist_path: str) -> None:
    if not os.path.exists(plist_path):
        print(f"  ⚠️  plist 不存在: {plist_path}，跳过状态栏配置")
        return

    # 备份
    backup = plist_path + ".bak"
    shutil.copy2(plist_path, backup)

    with open(plist_path, "rb") as f:
        prefs = plistlib.load(f)

    profiles = prefs.get("New Bookmarks", [])
    if not profiles:
        print("  ⚠️  未找到 iTerm2 Profile，跳过状态栏配置")
        os.remove(backup)
        return

    modified = False
    for profile in profiles:
        # 只修改 Default 或第一个 profile
        name = profile.get("Name", "")
        if name not in ("Default", "") and profiles.index(profile) != 0:
            continue

        # 启用状态栏
        profile["Status Bar Enabled"] = True

        # 确保 Status Bar Layout 结构存在
        layout = profile.setdefault("Status Bar Layout", {})
        layout.setdefault("advanced configuration", {"auto rainbow style": 0})
        components = layout.setdefault("components", [])

        # 避免重复添加
        already_added = any(
            c.get("configuration", {}).get("iTermStatusBarComponentIdentifier") == COMPONENT_ID
            for c in components
            if isinstance(c, dict)
        )
        if not already_added:
            components.insert(0, COMPONENT_ENTRY)
            modified = True
        break

    if modified:
        with open(plist_path, "wb") as f:
            plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)
        os.remove(backup)
    else:
        print("  ℹ️  组件已存在，无需重复添加")
        os.remove(backup)


def remove(plist_path: str) -> None:
    if not os.path.exists(plist_path):
        return
    with open(plist_path, "rb") as f:
        prefs = plistlib.load(f)
    profiles = prefs.get("New Bookmarks", [])
    modified = False
    for profile in profiles:
        layout = profile.get("Status Bar Layout", {})
        components = layout.get("components", [])
        before = len(components)
        layout["components"] = [
            c for c in components
            if isinstance(c, dict)
            and c.get("configuration", {}).get("iTermStatusBarComponentIdentifier") != COMPONENT_ID
        ]
        if len(layout["components"]) < before:
            modified = True
    if modified:
        with open(plist_path, "wb") as f:
            plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)


if __name__ == "__main__":
    args = sys.argv[1:]
    remove_mode = "--remove" in args
    args = [a for a in args if a != "--remove"]
    plist = args[0] if args else os.path.expanduser(
        "~/Library/Preferences/com.googlecode.iterm2.plist"
    )
    if remove_mode:
        remove(plist)
    else:
        configure(plist)
