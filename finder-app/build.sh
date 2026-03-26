#!/usr/bin/env bash
# build.sh — 编译并打包 "cd to iTerm2.app"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="cd to iTerm2"
DIST_DIR="$SCRIPT_DIR/../dist"
APP_PATH="$DIST_DIR/$APP_NAME.app"
ENTITLEMENTS="$SCRIPT_DIR/cd_to_iterm.entitlements"

mkdir -p "$DIST_DIR"

echo "▶  编译 AppleScript App ..."
osacompile -o "$APP_PATH" "$SCRIPT_DIR/cd_to_iterm.applescript"

# ── Info.plist ────────────────────────────────────────────────────────────────
PLIST="$APP_PATH/Contents/Info.plist"

/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :LSUIElement true" "$PLIST"

/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string io.github.iterm-cd.finder-app" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier io.github.iterm-cd.finder-app" "$PLIST"

/usr/libexec/PlistBuddy -c "Add :CFBundleName string 'cd to iTerm2'" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleName 'cd to iTerm2'" "$PLIST"

/usr/libexec/PlistBuddy -c "Add :NSAppleEventsUsageDescription string 'Queries Finder to get the current directory and opens it in iTerm2'" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :NSAppleEventsUsageDescription 'Queries Finder to get the current directory and opens it in iTerm2'" "$PLIST"

# ── 先移除隔离标记，再 codesign（顺序很重要：签名后不能再改 xattrs）────────────
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# ── Ad-hoc codesign ───────────────────────────────────────────────────────────
codesign --force --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"

# ── 打包 zip（--noqtn 阻止 quarantine 传入 zip，保留其他 xattrs 含签名）────────
ZIP_PATH="$DIST_DIR/cd-to-iTerm2.zip"
rm -f "$ZIP_PATH"
ditto -c -k --noqtn --keepParent "$APP_PATH" "$ZIP_PATH"

echo "✅  构建完成: $APP_PATH"
echo "✅  打包完成: $ZIP_PATH"
