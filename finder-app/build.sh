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

# 关键：告诉 macOS 为什么需要 Apple Events，触发系统权限弹窗
/usr/libexec/PlistBuddy -c "Add :NSAppleEventsUsageDescription string 'Queries Finder to get current directory and opens it in iTerm2'" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :NSAppleEventsUsageDescription 'Queries Finder to get current directory and opens it in iTerm2'" "$PLIST"

# ── Entitlements ──────────────────────────────────────────────────────────────
cat > "$ENTITLEMENTS" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
EOF

# ── Ad-hoc codesign（写入 entitlement，让 macOS 正确识别权限需求）─────────────
codesign --force --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"

# ── 移除隔离标记 ──────────────────────────────────────────────────────────────
xattr -cr "$APP_PATH"

echo "✅  构建完成: $APP_PATH"
