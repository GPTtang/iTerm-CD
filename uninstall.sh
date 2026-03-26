#!/usr/bin/env bash
# uninstall.sh — 卸载 cd to iTerm2

set -euo pipefail

APP_PATH="/Applications/cd to iTerm2.app"

# ── 1. 退出 Finder，让它把内存状态写回 plist ──────────────────────────────────
osascript -e 'tell application "Finder" to quit' 2>/dev/null || true
sleep 1

# ── 2. 从 Finder 工具栏 plist 中移除条目 ─────────────────────────────────────
python3 - <<'PYEOF'
import plistlib, os

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
    tb_config  = prefs[toolbar_key]
    # 自定义 App 存在 TB Item Plists（dict），key 是序号字符串"1","2"...
    # TB Item Identifiers 中对应位置是 "com.apple.finder.loc "
    item_plists = tb_config.get("TB Item Plists", {})
    item_ids    = list(tb_config.get("TB Item Identifiers", []))

    # 找出所有指向目标 App 的序号
    keys_to_remove = []
    for k, v in item_plists.items():
        alias = v.get("_CFURLAliasData", b"")
        url   = v.get("_CFURLString", "")
        if app_name in str(alias) or app_name in url:
            keys_to_remove.append(int(k))

    if keys_to_remove:
        # 按序号从大到小处理，避免下标偏移
        for key_num in sorted(keys_to_remove, reverse=True):
            # 移除 TB Item Identifiers 中第 key_num 个 "com.apple.finder.loc "
            count = 0
            for i, item in enumerate(item_ids):
                if item == "com.apple.finder.loc ":
                    count += 1
                    if count == key_num:
                        item_ids.pop(i)
                        break
            del item_plists[str(key_num)]

        # 重新连续编号
        remaining = sorted(item_plists.keys(), key=lambda x: int(x))
        tb_config["TB Item Plists"]      = {str(i + 1): item_plists[k] for i, k in enumerate(remaining)}
        tb_config["TB Item Identifiers"] = item_ids
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
