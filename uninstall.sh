#!/usr/bin/env bash
# uninstall.sh — 卸载 cd to iTerm2

set -euo pipefail

APP_PATH="/Applications/cd to iTerm2.app"

# ── 1. 从 Finder 工具栏移除 ────────────────────────────────────────────────────
python3 - "$APP_PATH" <<'PYEOF'
import plistlib, subprocess, sys

app_path = sys.argv[1]

# 导出当前 Finder 偏好设置
result = subprocess.run(
    ["defaults", "export", "com.apple.finder", "-"],
    capture_output=True
)
if result.returncode != 0:
    sys.exit(0)

prefs = plistlib.loads(result.stdout)
toolbar_key = "NSToolbar Configuration Browser"
changed = False

if toolbar_key in prefs:
    tb_config = prefs[toolbar_key]
    for key in ("TB Item Identifiers", "TB Default Item Identifiers"):
        if key in tb_config:
            before = tb_config[key]
            after = [item for item in before if item != app_path]
            if len(after) != len(before):
                tb_config[key] = after
                changed = True

if changed:
    data = plistlib.dumps(prefs, fmt=plistlib.FMT_XML)
    subprocess.run(["defaults", "import", "com.apple.finder", "-"], input=data, check=True)
    print("✅  已从 Finder 工具栏移除")
else:
    print("ℹ️   Finder 工具栏中未找到该 App（可能未添加）")
PYEOF

# ── 2. 移除 App 文件 ───────────────────────────────────────────────────────────
pkill -x "cd to iTerm2" 2>/dev/null || true
if [[ -d "$APP_PATH" ]]; then
  rm -rf "$APP_PATH"
  echo "✅  已移除 App"
fi

# ── 3. 移除 Quick Action ───────────────────────────────────────────────────────
if [[ -d "$HOME/Library/Services/cd to iTerm2.workflow" ]]; then
  rm -rf "$HOME/Library/Services/cd to iTerm2.workflow"
  /System/Library/CoreServices/pbs -update
  echo "✅  已移除 Finder 快速操作"
fi

# ── 4. 重启 Finder 使工具栏变更生效 ───────────────────────────────────────────
killall Finder
echo "✅  卸载完成"
