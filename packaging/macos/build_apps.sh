#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "${0:A:h}" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
DIST_DIR="$REPO_DIR/dist/macos"
INSTALLER_APP="$DIST_DIR/iTerm CD Installer.app"
UNINSTALLER_APP="$DIST_DIR/iTerm CD Uninstaller.app"
INSTALLER_ZIP="$DIST_DIR/iTerm CD Installer.zip"
UNINSTALLER_ZIP="$DIST_DIR/iTerm CD Uninstaller.zip"
INSTALLER_ICON="$DIST_DIR/icons/iTerm CD Installer.icns"
UNINSTALLER_ICON="$DIST_DIR/icons/iTerm CD Uninstaller.icns"
PYTHON_SCRIPT="$REPO_DIR/scripts/iterm_cd_to_current.py"

. "$SCRIPT_DIR/common.sh"

if [[ ! -f "$PYTHON_SCRIPT" ]]; then
  echo "未找到脚本文件: $PYTHON_SCRIPT" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

zsh "$SCRIPT_DIR/build_icons.sh" >/dev/null

if [[ -d "$INSTALLER_APP" ]]; then
  rm -rf "$INSTALLER_APP"
fi

if [[ -d "$UNINSTALLER_APP" ]]; then
  rm -rf "$UNINSTALLER_APP"
fi

rm -f "$INSTALLER_ZIP" "$UNINSTALLER_ZIP"

osacompile -l JavaScript -o "$INSTALLER_APP" "$SCRIPT_DIR/installer.js"
osacompile -l JavaScript -o "$UNINSTALLER_APP" "$SCRIPT_DIR/uninstaller.js"

cp "$SCRIPT_DIR/install_payload.sh" "$INSTALLER_APP/Contents/Resources/install_payload.sh"
mkdir -p "$INSTALLER_APP/Contents/Resources/payload"
cp "$PYTHON_SCRIPT" "$INSTALLER_APP/Contents/Resources/payload/iterm_cd_to_current.py"

cp "$SCRIPT_DIR/uninstall_payload.sh" "$UNINSTALLER_APP/Contents/Resources/uninstall_payload.sh"

chmod +x "$INSTALLER_APP/Contents/Resources/install_payload.sh"
chmod +x "$INSTALLER_APP/Contents/Resources/payload/iterm_cd_to_current.py"
chmod +x "$UNINSTALLER_APP/Contents/Resources/uninstall_payload.sh"

configure_app_bundle_metadata "$INSTALLER_APP" "com.liyong.iterm-cd.installer" "iTerm CD Installer"
configure_app_bundle_metadata "$UNINSTALLER_APP" "com.liyong.iterm-cd.uninstaller" "iTerm CD Uninstaller"
apply_app_icon "$INSTALLER_APP" "$INSTALLER_ICON"
apply_app_icon "$UNINSTALLER_APP" "$UNINSTALLER_ICON"

sign_app_bundle "$INSTALLER_APP"
sign_app_bundle "$UNINSTALLER_APP"
notarize_app_bundle "$INSTALLER_APP" "$INSTALLER_ZIP"
notarize_app_bundle "$UNINSTALLER_APP" "$UNINSTALLER_ZIP"

cat <<EOF
已生成:
  $INSTALLER_APP
  $UNINSTALLER_APP

图标:
  $INSTALLER_ICON
  $UNINSTALLER_ICON

EOF

if [[ -f "$INSTALLER_ZIP" || -f "$UNINSTALLER_ZIP" ]]; then
  cat <<EOF
附加产物:
  $INSTALLER_ZIP
  $UNINSTALLER_ZIP

使用方式:
1. 双击 iTerm CD Installer.app 安装
2. 双击 iTerm CD Uninstaller.app 卸载
EOF
else
  cat <<EOF
使用方式:
1. 双击 iTerm CD Installer.app 安装
2. 双击 iTerm CD Uninstaller.app 卸载
EOF
fi
