#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "${0:A:h}" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
DIST_DIR="$REPO_DIR/dist/macos"
ICON_DIR="$DIST_DIR/icons"
INSTALLER_SVG="$REPO_DIR/assets/macos/installer-icon.svg"
UNINSTALLER_SVG="$REPO_DIR/assets/macos/uninstaller-icon.svg"
TMP_DIR=$(mktemp -d /tmp/iterm-cd-icons.XXXXXX)

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! command -v qlmanage >/dev/null 2>&1; then
  echo "缺少工具: qlmanage" >&2
  exit 1
fi

if ! command -v iconutil >/dev/null 2>&1; then
  echo "缺少工具: iconutil" >&2
  exit 1
fi

mkdir -p "$ICON_DIR"

render_png() {
  local source_svg="$1"
  local target_size="$2"
  local output_path="$3"
  local output_dir
  local output_name

  output_dir=$(dirname "$output_path")
  output_name=$(basename "$source_svg")

  qlmanage -t -s "$target_size" -o "$output_dir" "$source_svg" >/dev/null 2>&1
  mv "$output_dir/$output_name.png" "$output_path"
}

render_iconset() {
  local source_svg="$1"
  local output_name="$2"
  local iconset_dir="$TMP_DIR/$output_name.iconset"

  mkdir -p "$iconset_dir"

  for base_size in 16 32 128 256 512; do
    local png_1x="$iconset_dir/icon_${base_size}x${base_size}.png"
    local png_2x="$iconset_dir/icon_${base_size}x${base_size}@2x.png"
    render_png "$source_svg" "$base_size" "$png_1x"
    render_png "$source_svg" "$((base_size * 2))" "$png_2x"
  done

  iconutil -c icns "$iconset_dir" -o "$ICON_DIR/$output_name.icns"
}

render_iconset "$INSTALLER_SVG" "iTerm CD Installer"
render_iconset "$UNINSTALLER_SVG" "iTerm CD Uninstaller"

cat <<EOF
已生成:
  $ICON_DIR/iTerm CD Installer.icns
  $ICON_DIR/iTerm CD Uninstaller.icns
EOF
