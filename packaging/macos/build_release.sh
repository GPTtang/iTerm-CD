#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "${0:A:h}" && pwd)

zsh "$SCRIPT_DIR/build_apps.sh"
SKIP_BUILD_APPS=1 zsh "$SCRIPT_DIR/build_pkg.sh"
SKIP_BUILD_APPS=1 SKIP_BUILD_PKG=1 zsh "$SCRIPT_DIR/build_dmg.sh"
