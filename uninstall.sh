#!/usr/bin/env bash
# uninstall.sh — uninstall cd to iTerm2

set -euo pipefail

APP_PATH="/Applications/cd to iTerm2.app"

# ── 1. Quit Finder so it flushes in-memory state to plist ────────────────────
osascript -e 'tell application "Finder" to quit' 2>/dev/null || true
sleep 1

# ── 2. Remove entry from Finder toolbar plist ─────────────────────────────────
python3 - <<'PYEOF'
import plistlib, os

plist_path = os.path.expanduser("~/Library/Preferences/com.apple.finder.plist")
app_name   = "cd to iTerm2"

if not os.path.exists(plist_path):
    print("ℹ️   Finder plist not found, skipping toolbar cleanup")
    exit(0)

with open(plist_path, "rb") as f:
    prefs = plistlib.load(f)

toolbar_key = "NSToolbar Configuration Browser"
changed = False

if toolbar_key in prefs:
    tb_config  = prefs[toolbar_key]
    # Custom apps are stored in TB Item Plists (dict), keys are sequential strings "1","2"...
    # Corresponding positions in TB Item Identifiers use "com.apple.finder.loc "
    item_plists = tb_config.get("TB Item Plists", {})
    item_ids    = list(tb_config.get("TB Item Identifiers", []))

    # Find all keys pointing to the target app
    keys_to_remove = []
    for k, v in item_plists.items():
        alias = v.get("_CFURLAliasData", b"")
        url   = v.get("_CFURLString", "")
        if app_name in str(alias) or app_name in url:
            keys_to_remove.append(int(k))

    if keys_to_remove:
        # Process in descending order to avoid index shifting
        for key_num in sorted(keys_to_remove, reverse=True):
            # Remove the key_num-th "com.apple.finder.loc " from TB Item Identifiers
            count = 0
            for i, item in enumerate(item_ids):
                if item == "com.apple.finder.loc ":
                    count += 1
                    if count == key_num:
                        item_ids.pop(i)
                        break
            del item_plists[str(key_num)]

        # Renumber remaining keys sequentially
        remaining = sorted(item_plists.keys(), key=lambda x: int(x))
        tb_config["TB Item Plists"]      = {str(i + 1): item_plists[k] for i, k in enumerate(remaining)}
        tb_config["TB Item Identifiers"] = item_ids
        changed = True

if changed:
    with open(plist_path, "wb") as f:
        plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)
    print("✅  Removed from Finder toolbar")
else:
    print("ℹ️   App not found in Finder toolbar (may not have been added)")
PYEOF

# ── 3. Remove app file ────────────────────────────────────────────────────────
pkill -x "cd to iTerm2" 2>/dev/null || true
if [[ -d "$APP_PATH" ]]; then
  rm -rf "$APP_PATH"
  echo "✅  App removed"
fi

# ── 4. Remove Quick Action ────────────────────────────────────────────────────
if [[ -d "$HOME/Library/Services/cd to iTerm2.workflow" ]]; then
  rm -rf "$HOME/Library/Services/cd to iTerm2.workflow"
  /System/Library/CoreServices/pbs -update
  echo "✅  Quick Action removed"
fi

# ── 5. Reopen Finder ──────────────────────────────────────────────────────────
open -a Finder
echo "✅  Uninstall complete"
