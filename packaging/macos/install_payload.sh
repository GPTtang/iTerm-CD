#!/bin/zsh

set -euo pipefail

RESOURCE_DIR=$(cd "${0:A:h}" && pwd)
SOURCE_SCRIPT="$RESOURCE_DIR/payload/iterm_cd_to_current.py"
TARGET_DIR="$HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
TARGET_SCRIPT="$TARGET_DIR/iterm_cd_to_current.py"

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo "安装失败：未找到内置脚本。"
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"

cat <<EOF
安装完成

已写入:
$TARGET_SCRIPT

下一步:
1. 重启 iTerm2，或在 Scripts 菜单里手动运行 iterm_cd_to_current.py
2. Settings > Profiles > Session > 打开 Status bar enabled
3. Configure Status Bar > 拖入 CD To Current Directory

如果当前目录无法识别，请先启用 iTerm2 Shell Integration。
EOF
