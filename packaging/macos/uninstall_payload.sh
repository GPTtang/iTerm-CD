#!/bin/zsh

set -euo pipefail

TARGET_DIR="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
TARGET_SCRIPT="$TARGET_DIR/iterm_cd_to_current.py"

if [[ -e "$TARGET_SCRIPT" || -L "$TARGET_SCRIPT" ]]; then
  rm -f "$TARGET_SCRIPT"
  REMOVAL_STATUS="已删除:
$TARGET_SCRIPT"
else
  REMOVAL_STATUS="未发现已安装脚本:
$TARGET_SCRIPT"
fi

clear_badges() {
  osascript <<'APPLESCRIPT'
tell application "iTerm2"
  if not (exists current window) then
    return
  end if

  set clearCommand to "printf '\033]1337;SetBadgeFormat=%s\a' ''"

  repeat with aWindow in windows
    repeat with aTab in tabs of aWindow
      repeat with aSession in sessions of aTab
        tell aSession
          write text clearCommand
        end tell
      end repeat
    end repeat
  end repeat
end tell
APPLESCRIPT
}

BADGE_STATUS="iTerm2 当前未运行，跳过 badge 清理。"
if pgrep -x "iTerm2" >/dev/null 2>&1; then
  if clear_badges >/dev/null 2>&1; then
    BADGE_STATUS="已尝试清空当前打开 session 的 badge。"
  else
    BADGE_STATUS="已卸载脚本，但未能自动清空当前打开 session 的 badge。"
  fi
fi

cat <<EOF
卸载完成

$REMOVAL_STATUS

$BADGE_STATUS

后续处理:
1. 重启 iTerm2，状态栏组件和标题提供器会一起消失
2. 如果某个 profile 里还保留空白占位，手动打开 Status Bar 配置拖出该组件即可
EOF
