#!/usr/bin/env bash
# install.sh — cd to iTerm2 一键安装

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DEST="/Applications/cd to iTerm2.app"

# ── 检查 iTerm2 ──────────────────────────────────────────────────────────────
if ! ls /Applications/iTerm.app &>/dev/null && ! ls ~/Applications/iTerm.app &>/dev/null; then
  echo "❌  未找到 iTerm2，请先安装: https://iterm2.com/"
  exit 1
fi

echo "▶  安装 cd to iTerm2 ..."
echo ""

# ── 1. 构建 App ───────────────────────────────────────────────────────────────
bash "$SCRIPT_DIR/finder-app/build.sh"
echo ""

# ── 2. 安装 App 到 /Applications ─────────────────────────────────────────────
pkill -x "cd to iTerm2" 2>/dev/null || true   # 如已运行先退出
cp -rf "$SCRIPT_DIR/dist/cd to iTerm2.app" /Applications/
echo "✅  [1/3] Finder 工具栏 App 已安装"

# ── 3. 安装 Quick Action ──────────────────────────────────────────────────────
python3 "$SCRIPT_DIR/scripts/build_workflow.py"
/System/Library/CoreServices/pbs -update
echo "✅  [2/3] Finder 快速操作已安装"

# ── 4. 触发首次权限授权 ───────────────────────────────────────────────────────
open "$APP_DEST"
echo "✅  [3/3] 已启动 App，请在弹窗中完成授权"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  安装完成！"
echo ""
echo "  授权步骤（只需一次）："
echo "  弹窗中点「去授权」→ 系统设置中勾选 Finder → 完成"
echo ""
echo "  添加到 Finder 工具栏："
echo "  按住 ⌘，将 /Applications/cd to iTerm2.app 拖入 Finder 工具栏"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
