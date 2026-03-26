#!/usr/bin/env bash
# uninstall.sh — 卸载 iTerm CD To Current

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch/iterm_cd_to_current.py"
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# 移除 AutoLaunch 脚本
if [[ -f "$TARGET" ]]; then
  rm "$TARGET"
  echo "✅  已移除: $TARGET"
else
  echo "ℹ️   脚本未安装，跳过"
fi

# 从状态栏移除组件
python3 "$SCRIPT_DIR/scripts/configure_statusbar.py" "$PLIST" --remove
echo "✅  状态栏组件已移除"

echo ""
echo "如需彻底清除 Shell Integration，从 ~/.zshrc 中删除以下行："
echo "  source ~/.iterm2_shell_integration.zsh"
