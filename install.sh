#!/usr/bin/env bash
# install.sh — cd to iTerm2 one-command installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DEST="/Applications/cd to iTerm2.app"

# ── Check for iTerm2 ──────────────────────────────────────────────────────────
if ! ls /Applications/iTerm.app &>/dev/null && ! ls ~/Applications/iTerm.app &>/dev/null; then
  echo "❌  iTerm2 not found. Please install it first: https://iterm2.com/"
  exit 1
fi

echo "▶  Installing cd to iTerm2 ..."
echo ""

# ── 1. Build app ──────────────────────────────────────────────────────────────
bash "$SCRIPT_DIR/finder-app/build.sh"
echo ""

# ── 2. Install app to /Applications ──────────────────────────────────────────
pkill -x "cd to iTerm2" 2>/dev/null || true   # quit if already running
cp -rf "$SCRIPT_DIR/dist/cd to iTerm2.app" /Applications/
echo "✅  [1/3] Finder toolbar app installed"

# ── 3. Install Quick Action ───────────────────────────────────────────────────
python3 "$SCRIPT_DIR/scripts/build_workflow.py"
/System/Library/CoreServices/pbs -update
echo "✅  [2/3] Finder Quick Action installed"

# ── 4. Launch app to trigger first-time permission prompt ─────────────────────
open "$APP_DEST"
echo "✅  [3/3] App launched — please complete authorization in the dialog"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  Authorization (one-time only):"
echo "  Click \"Open Settings\" in the dialog → enable Finder → done"
echo ""
echo "  Add to Finder toolbar:"
echo "  Hold ⌘ and drag /Applications/cd to iTerm2.app into the Finder toolbar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
