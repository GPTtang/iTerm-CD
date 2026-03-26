#!/usr/bin/env bash
# uninstall.sh — 卸载 cd to iTerm2

set -euo pipefail

APP_PATH="/Applications/cd to iTerm2.app"

# ── 1. 退出 Finder，让它把内存状态写回 plist ──────────────────────────────────
osascript -e 'tell application "Finder" to quit' 2>/dev/null || true
sleep 1

# ── 2. 从 Finder 工具栏 plist 中移除条目 ─────────────────────────────────────
python3 - <<'PYEOF'
import plistlib, os, time, subprocess

plist_path = os.path.expanduser("~/Library/Preferences/com.apple.finder.plist")
app_name   = "cd to iTerm2"

if not os.path.exists(plist_path):
    print("ℹ️   未找到 Finder plist，跳过工具栏清理")
    exit(0)

with open(plist_path, "rb") as f:
    prefs = plistlib.load(f)

toolbar_key = "NSToolbar Configuration Browser"
changed = False

if toolbar_key in prefs:
    tb_config = prefs[toolbar_key]
    for key in ("TB Item Identifiers", "TB Default Item Identifiers"):
        if key in tb_config:
            before = tb_config[key]
            after  = [item for item in before if app_name not in str(item)]
            if len(after) != len(before):
                tb_config[key] = after
                changed = True

if changed:
    with open(plist_path, "wb") as f:
        plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)
    print("✅  已从 Finder 工具栏移除")
else:
    print("ℹ️   Finder 工具栏中未找到该 App（可能未添加）")
PYEOF

# ── 3. 移除 App 文件 ───────────────────────────────────────────────────────────
pkill -x "cd to iTerm2" 2>/dev/null || true
if [[ -d "$APP_PATH" ]]; then
  rm -rf "$APP_PATH"
  echo "✅  已移除 App"
fi

# ── 4. 移除 Quick Action ───────────────────────────────────────────────────────
if [[ -d "$HOME/Library/Services/cd to iTerm2.workflow" ]]; then
  rm -rf "$HOME/Library/Services/cd to iTerm2.workflow"
  /System/Library/CoreServices/pbs -update
  echo "✅  已移除 Finder 快速操作"
fi

# ── 5. 重新打开 Finder ────────────────────────────────────────────────────────
open -a Finder
echo "✅  卸载完成"
