#!/usr/bin/env bash
# install.sh — cd to iTerm2 一键安装

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 检查 iTerm2 ──────────────────────────────────────────────────────────────
if ! open -Ra iTerm 2>/dev/null; then
  echo "❌  未找到 iTerm2。请先安装: https://iterm2.com/"
  exit 1
fi

echo "▶  开始安装 cd to iTerm2 ..."
echo ""

# ── 1. 构建并安装 Finder 工具栏 App ──────────────────────────────────────────
bash "$SCRIPT_DIR/finder-app/build.sh" > /dev/null
cp -rf "$SCRIPT_DIR/dist/cd to iTerm2.app" /Applications/
echo "✅  [1/3] Finder 工具栏 App 已安装"

# ── 2. 安装 Finder Quick Action ───────────────────────────────────────────────
python3 "$SCRIPT_DIR/scripts/build_workflow.py" > /dev/null
/System/Library/CoreServices/pbs -update
echo "✅  [2/3] Finder 快速操作已安装"

# ── 3. 触发 Finder 权限授权 ───────────────────────────────────────────────────
echo "✅  [3/3] 触发权限授权..."
open /Applications/"cd to iTerm2.app"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  安装完成！"
echo ""
echo "  1. 在弹出的权限询问框中点「去授权」→ 系统设置中勾选 Finder"
echo "  2. 打开 Finder，按住 ⌘ 将 App 拖入工具栏即可使用"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
