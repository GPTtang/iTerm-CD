#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=${0:A:h}
SOURCE_SCRIPT="$SCRIPT_DIR/scripts/iterm_cd_to_current.py"
TARGET_DIR="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
TARGET_SCRIPT="$TARGET_DIR/iterm_cd_to_current.py"
MODE="copy"

usage() {
  cat <<'EOF'
用法:
  ./install.sh
  ./install.sh --link

默认行为:
  把 scripts/iterm_cd_to_current.py 复制到 iTerm2 AutoLaunch 目录

可选参数:
  --link    使用软链接，便于后续修改脚本后立即生效
  -h
  --help    显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link)
      MODE="link"
      shift
      ;;
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
done

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo "未找到源脚本: $SOURCE_SCRIPT" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [[ -e "$TARGET_SCRIPT" || -L "$TARGET_SCRIPT" ]]; then
  rm -f "$TARGET_SCRIPT"
fi

if [[ "$MODE" == "link" ]]; then
  ln -s "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
  echo "已创建软链接:"
else
  cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
  echo "已复制脚本:"
fi

chmod +x "$TARGET_SCRIPT"

cat <<EOF
  $TARGET_SCRIPT

下一步:
1. 重启 iTerm2，或在 Scripts 菜单里手动运行 iterm_cd_to_current.py
2. Settings > Profiles > Session > 打开 Status bar enabled
3. Configure Status Bar > 拖入 CD To Current Directory
4. 需要卸载时可运行 ./uninstall.sh

如果当前目录无法识别，请先启用 iTerm2 Shell Integration。
EOF
