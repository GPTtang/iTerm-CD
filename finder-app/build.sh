#!/usr/bin/env bash
# build.sh — compile and package "cd to iTerm2.app"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="cd to iTerm2"
DIST_DIR="$SCRIPT_DIR/../dist"
APP_PATH="$DIST_DIR/$APP_NAME.app"
ENTITLEMENTS="$SCRIPT_DIR/cd_to_iterm.entitlements"

mkdir -p "$DIST_DIR"

echo "▶  Compiling AppleScript app ..."
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

# ── Remove quarantine before codesign (order matters: xattrs must not change after signing) ──
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# ── Ad-hoc codesign ───────────────────────────────────────────────────────────
codesign --force --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"

# ── Package zip (--noqtn prevents quarantine in zip, preserves other xattrs including signature) ──
ZIP_PATH="$DIST_DIR/cd-to-iTerm2.zip"
rm -f "$ZIP_PATH"
ditto -c -k --noqtn --keepParent "$APP_PATH" "$ZIP_PATH"

echo "✅  Build complete: $APP_PATH"
echo "✅  Package complete: $ZIP_PATH"
