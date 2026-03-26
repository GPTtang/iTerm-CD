#!/usr/bin/env bash
# install.sh — iTerm CD To Current 一键安装

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ITERM2_SCRIPTS_DIR="$HOME/Library/Application Support/iTerm2/Scripts"
AUTOLAUNCH_DIR="$ITERM2_SCRIPTS_DIR/AutoLaunch"
TARGET="$AUTOLAUNCH_DIR/iterm_cd_to_current.py"
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# ── 检查 iTerm2 ──────────────────────────────────────────────────────────────
if ! open -Ra iTerm 2>/dev/null; then
  echo "❌  未找到 iTerm2。请先安装: https://iterm2.com/"
  exit 1
fi

echo "▶  开始安装 iTerm CD To Current ..."
echo ""

# ── 1. 安装 AutoLaunch 脚本 ──────────────────────────────────────────────────
mkdir -p "$AUTOLAUNCH_DIR"
cp "$SCRIPT_DIR/scripts/iterm_cd_to_current.py" "$TARGET"
chmod +x "$TARGET"
echo "✅  [1/5] 脚本已安装: $TARGET"

# ── 2. 安装 Shell Integration ────────────────────────────────────────────────
SHELL_INT_FILE="$HOME/.iterm2_shell_integration.zsh"
if [[ ! -f "$SHELL_INT_FILE" ]]; then
  echo "    正在下载 Shell Integration ..."
  curl -sL "https://iterm2.com/shell_integration/zsh" -o "$SHELL_INT_FILE"
fi
if ! grep -q "iterm2_shell_integration" "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# iTerm2 Shell Integration\nsource ~/.iterm2_shell_integration.zsh\n' >> "$HOME/.zshrc"
fi
echo "✅  [2/5] Shell Integration 已安装 (~/.zshrc 已更新)"

# ── 3. 配置状态栏（用 Python plistlib 直接写入 iTerm2 配置）───────────────────
python3 "$SCRIPT_DIR/scripts/configure_statusbar.py" "$PLIST"
echo "✅  [3/5] 状态栏已配置（已启用 + 组件已添加）"

# ── 4. 构建并安装 Finder 工具栏 App + 快速操作 ───────────────────────────────
bash "$SCRIPT_DIR/finder-app/build.sh" > /dev/null
cp -rf "$SCRIPT_DIR/dist/cd to iTerm2.app" "$HOME/Applications/"
python3 "$SCRIPT_DIR/scripts/build_workflow.py" > /dev/null
/System/Library/CoreServices/pbs -update
echo "✅  [4/5] Finder App + 快速操作已安装"

# 首次运行 App，触发 macOS 权限请求（让 App 出现在系统设置自动操作列表中）
open "$HOME/Applications/cd to iTerm2.app"
sleep 1  # 等待权限弹窗出现

# ── 5. 用 AppleScript 打开 Python Runtime 安装界面 ───────────────────────────
echo "    [5/5] 正在打开 Python Runtime 安装界面 ..."

# 通过菜单栏点击触发安装（Scripts > Manage > Install Python Runtime）
osascript <<'EOF' 2>/dev/null || true
tell application "System Events"
  tell process "iTerm2"
    click menu item "Manage" of menu "Scripts" of menu bar 1
    delay 0.5
    click menu item "Install Python Runtime" of menu 1 of menu item "Manage" of menu "Scripts" of menu bar 1
  end tell
end tell
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  安装完成！"
echo ""
echo "  如果没有自动弹出安装窗口，手动操作（只需一次）："
echo "  iTerm2 菜单 → Scripts → Manage → Install Python Runtime → 点 Install"
echo ""
echo "  安装完成后重新打开一个 iTerm2 窗口，状态栏即显示 'cd to...' 组件。"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
