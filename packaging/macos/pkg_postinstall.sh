#!/bin/zsh

set -euo pipefail

SOURCE_SCRIPT="/Library/Application Support/iTerm-CD/iterm_cd_to_current.py"
CONSOLE_USER=$(stat -f '%Su' /dev/console 2>/dev/null || true)

if [[ -z "$CONSOLE_USER" || "$CONSOLE_USER" == "root" ]]; then
  exit 0
fi

USER_HOME=$(dscl . -read "/Users/$CONSOLE_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
if [[ -z "$USER_HOME" ]]; then
  USER_HOME=$(eval echo "~$CONSOLE_USER")
fi

if [[ -z "$USER_HOME" || ! -d "$USER_HOME" ]]; then
  exit 0
fi

TARGET_DIR="$USER_HOME/Library/Application Support/iTerm2/Scripts/AutoLaunch"
TARGET_SCRIPT="$TARGET_DIR/iterm_cd_to_current.py"
USER_GROUP=$(id -gn "$CONSOLE_USER")

mkdir -p "$TARGET_DIR"
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
chown "$CONSOLE_USER:$USER_GROUP" "$TARGET_SCRIPT"
chown "$CONSOLE_USER:$USER_GROUP" "$TARGET_DIR"
