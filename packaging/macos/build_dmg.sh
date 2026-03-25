#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "${0:A:h}" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
DIST_DIR="$REPO_DIR/dist/macos"
DMG_PATH="$DIST_DIR/iTerm-CD-macOS.dmg"
STAGE_DIR=$(mktemp -d /tmp/iterm-cd-dmg.XXXXXX)

. "$SCRIPT_DIR/common.sh"

cleanup() {
  rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

if ! is_truthy "${SKIP_BUILD_APPS:-0}"; then
  zsh "$SCRIPT_DIR/build_apps.sh" >/dev/null
fi

if ! is_truthy "${SKIP_BUILD_PKG:-0}"; then
  SKIP_BUILD_APPS=1 zsh "$SCRIPT_DIR/build_pkg.sh" >/dev/null
fi

cp -R "$DIST_DIR/iTerm CD Installer.app" "$STAGE_DIR/"
cp -R "$DIST_DIR/iTerm CD Uninstaller.app" "$STAGE_DIR/"
cp "$DIST_DIR/iTerm CD Installer.pkg" "$STAGE_DIR/"
cp "$SCRIPT_DIR/DMG-README.txt" "$STAGE_DIR/README.txt"

if [[ -f "$DMG_PATH" ]]; then
  rm -f "$DMG_PATH"
fi

hdiutil create \
  -volname "iTerm CD" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

sign_dmg_file "$DMG_PATH"
notarize_dmg_file "$DMG_PATH"

cat <<EOF
已生成:
  $DMG_PATH

内容:
- iTerm CD Installer.pkg
- iTerm CD Installer.app
- iTerm CD Uninstaller.app
EOF
