#!/bin/zsh

RELEASE_VERSION="${RELEASE_VERSION:-1.0.0}"
ENABLE_SIGNING="${ENABLE_SIGNING:-0}"
ENABLE_NOTARIZATION="${ENABLE_NOTARIZATION:-0}"
DEVELOPER_ID_APPLICATION="${DEVELOPER_ID_APPLICATION:-}"
DEVELOPER_ID_INSTALLER="${DEVELOPER_ID_INSTALLER:-}"
NOTARYTOOL_PROFILE="${NOTARYTOOL_PROFILE:-}"
CODESIGN_KEYCHAIN="${CODESIGN_KEYCHAIN:-}"

typeset -ga CODESIGN_KEYCHAIN_ARGS=()
typeset -ga PKGBUILD_KEYCHAIN_ARGS=()

if [[ -n "$CODESIGN_KEYCHAIN" ]]; then
  CODESIGN_KEYCHAIN_ARGS=(--keychain "$CODESIGN_KEYCHAIN")
  PKGBUILD_KEYCHAIN_ARGS=(--keychain "$CODESIGN_KEYCHAIN")
fi

is_truthy() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

signing_enabled() {
  is_truthy "$ENABLE_SIGNING" || [[ -n "$DEVELOPER_ID_APPLICATION" || -n "$DEVELOPER_ID_INSTALLER" ]]
}

notarization_enabled() {
  is_truthy "$ENABLE_NOTARIZATION" || [[ -n "$NOTARYTOOL_PROFILE" ]]
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少工具: $1" >&2
    exit 1
  fi
}

require_app_signing_identity() {
  if signing_enabled && [[ -z "$DEVELOPER_ID_APPLICATION" ]]; then
    echo "已启用签名，但缺少 DEVELOPER_ID_APPLICATION。" >&2
    exit 1
  fi
}

require_installer_signing_identity() {
  if signing_enabled && [[ -z "$DEVELOPER_ID_INSTALLER" ]]; then
    echo "已启用签名，但缺少 DEVELOPER_ID_INSTALLER。" >&2
    exit 1
  fi
}

require_notary_profile() {
  if notarization_enabled && [[ -z "$NOTARYTOOL_PROFILE" ]]; then
    echo "已启用 notarization，但缺少 NOTARYTOOL_PROFILE。" >&2
    exit 1
  fi
}

set_plist_value() {
  local plist_path="$1"
  local key="$2"
  local value="$3"

  if /usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c "Set :$key $value" "$plist_path" >/dev/null
  else
    /usr/libexec/PlistBuddy -c "Add :$key string $value" "$plist_path" >/dev/null
  fi
}

configure_app_bundle_metadata() {
  local app_path="$1"
  local bundle_id="$2"
  local bundle_name="$3"
  local plist_path="$app_path/Contents/Info.plist"

  set_plist_value "$plist_path" "CFBundleIdentifier" "$bundle_id"
  set_plist_value "$plist_path" "CFBundleName" "$bundle_name"
  set_plist_value "$plist_path" "CFBundleDisplayName" "$bundle_name"
  set_plist_value "$plist_path" "CFBundleShortVersionString" "$RELEASE_VERSION"
  set_plist_value "$plist_path" "CFBundleVersion" "$RELEASE_VERSION"
  set_plist_value "$plist_path" "CFBundleIconFile" "applet"
}

apply_app_icon() {
  local app_path="$1"
  local icon_path="$2"
  local target_icon="$app_path/Contents/Resources/applet.icns"

  cp "$icon_path" "$target_icon"
}

sign_app_bundle() {
  local app_path="$1"

  if ! signing_enabled; then
    return 0
  fi

  require_tool codesign
  require_app_signing_identity

  codesign \
    --force \
    --deep \
    --timestamp \
    --options runtime \
    "${CODESIGN_KEYCHAIN_ARGS[@]}" \
    --sign "$DEVELOPER_ID_APPLICATION" \
    "$app_path"

  codesign --verify --deep --strict --verbose=2 "$app_path"
}

sign_dmg_file() {
  local dmg_path="$1"

  if ! signing_enabled; then
    return 0
  fi

  require_tool codesign
  require_app_signing_identity

  codesign \
    --force \
    --timestamp \
    "${CODESIGN_KEYCHAIN_ARGS[@]}" \
    --sign "$DEVELOPER_ID_APPLICATION" \
    "$dmg_path"
}

zip_app_bundle() {
  local app_path="$1"
  local zip_path="$2"

  require_tool ditto
  rm -f "$zip_path"
  ditto -c -k --sequesterRsrc --keepParent "$app_path" "$zip_path"
}

submit_for_notarization() {
  local path="$1"

  if ! notarization_enabled; then
    return 0
  fi

  require_tool xcrun
  require_notary_profile

  xcrun notarytool submit "$path" --keychain-profile "$NOTARYTOOL_PROFILE" --wait
}

staple_ticket() {
  local path="$1"

  if ! notarization_enabled; then
    return 0
  fi

  require_tool xcrun
  xcrun stapler staple "$path"
}

notarize_app_bundle() {
  local app_path="$1"
  local zip_path="$2"

  if ! notarization_enabled; then
    return 0
  fi

  zip_app_bundle "$app_path" "$zip_path"
  submit_for_notarization "$zip_path"
  staple_ticket "$app_path"
  zip_app_bundle "$app_path" "$zip_path"
}

notarize_pkg_file() {
  local pkg_path="$1"

  if ! notarization_enabled; then
    return 0
  fi

  submit_for_notarization "$pkg_path"
  staple_ticket "$pkg_path"
}

notarize_dmg_file() {
  local dmg_path="$1"

  if ! notarization_enabled; then
    return 0
  fi

  submit_for_notarization "$dmg_path"
  staple_ticket "$dmg_path"
}
