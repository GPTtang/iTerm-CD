#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "${0:A:h}" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
DIST_DIR="$REPO_DIR/dist/macos"
PKG_PATH="$DIST_DIR/iTerm CD Installer.pkg"
UNINSTALLER_APP="$DIST_DIR/iTerm CD Uninstaller.app"
SOURCE_SCRIPT="$REPO_DIR/scripts/iterm_cd_to_current.py"
TMP_DIR=$(mktemp -d /tmp/iterm-cd-pkg.XXXXXX)
ROOT_DIR="$TMP_DIR/root"
SCRIPTS_DIR="$TMP_DIR/scripts"

. "$SCRIPT_DIR/common.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! is_truthy "${SKIP_BUILD_APPS:-0}"; then
  zsh "$SCRIPT_DIR/build_apps.sh" >/dev/null
fi

mkdir -p "$ROOT_DIR/Library/Application Support/iTerm-CD"
mkdir -p "$ROOT_DIR/Applications"
mkdir -p "$SCRIPTS_DIR"

cp "$SOURCE_SCRIPT" "$ROOT_DIR/Library/Application Support/iTerm-CD/iterm_cd_to_current.py"
cp -R "$UNINSTALLER_APP" "$ROOT_DIR/Applications/iTerm CD Uninstaller.app"
cp "$SCRIPT_DIR/pkg_postinstall.sh" "$SCRIPTS_DIR/postinstall"
chmod +x "$SCRIPTS_DIR/postinstall"

if [[ -f "$PKG_PATH" ]]; then
  rm -f "$PKG_PATH"
fi

pkgbuild_args=(
  --root "$ROOT_DIR" \
  --scripts "$SCRIPTS_DIR" \
  --identifier "com.liyong.iterm-cd.installer" \
  --version "$RELEASE_VERSION" \
  --install-location "/" \
)

if signing_enabled; then
  require_installer_signing_identity
  pkgbuild_args+=(--sign "$DEVELOPER_ID_INSTALLER")
  if [[ ${#PKGBUILD_KEYCHAIN_ARGS[@]} -gt 0 ]]; then
    pkgbuild_args+=("${PKGBUILD_KEYCHAIN_ARGS[@]}")
  fi
fi

pkgbuild "${pkgbuild_args[@]}" "$PKG_PATH"

if signing_enabled; then
  pkgutil --check-signature "$PKG_PATH"
fi

notarize_pkg_file "$PKG_PATH"

cat <<EOF
已生成:
  $PKG_PATH

说明:
- 双击 pkg 会把脚本安装到当前登录用户的 iTerm2 AutoLaunch
- 同时会把 iTerm CD Uninstaller.app 安装到 /Applications
EOF
