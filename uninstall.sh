#!/bin/zsh

set -euo pipefail

TARGET_DIR="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
TARGET_SCRIPT="$TARGET_DIR/iterm_cd_to_current.py"

usage() {
  cat <<'EOF'
用法:
  ./uninstall.sh

行为:
  1. 删除 iTerm2 AutoLaunch 里的 iterm_cd_to_current.py
  2. 尝试清空当前已打开 session 的 badge
  3. 提示你重启 iTerm2，让状态栏组件和标题提供器一起消失
EOF
}

if [[ $# -gt 0 ]]; then
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
fi

if [[ -e "$TARGET_SCRIPT" || -L "$TARGET_SCRIPT" ]]; then
  rm -f "$TARGET_SCRIPT"
  echo "已删除:"
  echo "  $TARGET_SCRIPT"
else
  echo "未发现已安装脚本:"
  echo "  $TARGET_SCRIPT"
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

if pgrep -x "iTerm2" >/dev/null 2>&1; then
  if clear_badges >/dev/null 2>&1; then
    echo "已尝试清空当前打开 session 的 badge。"
  else
    echo "已卸载脚本，但未能自动清空当前打开 session 的 badge。"
  fi
else
  echo "iTerm2 当前未运行，跳过 badge 清理。"
fi

cat <<'EOF'

后续处理:
1. 重启 iTerm2，状态栏组件和标题提供器会一起消失
2. 如果某个 profile 里还保留了空白占位，手动打开 Status Bar 配置拖出该组件即可

说明:
- 卸载脚本会尽量把当前打开 session 的 badge 一起清掉
- 这是通过向当前 shell 发送一条 badge 清理命令实现的
EOF
