#!/bin/zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/SimpAlarm.app" >&2
  exit 1
fi

APP_DIR="$1"
IDENTITY="${DEVELOPER_ID_APP_SIGNING_IDENTITY:-}"

if [[ -z "$IDENTITY" ]]; then
  echo "DEVELOPER_ID_APP_SIGNING_IDENTITY is required to sign the app." >&2
  exit 1
fi

INFO_PLIST="$APP_DIR/Contents/Info.plist"
EXECUTABLE_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$INFO_PLIST")"
EXECUTABLE_PATH="$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"

if [[ ! -f "$EXECUTABLE_PATH" ]]; then
  echo "Executable not found at $EXECUTABLE_PATH" >&2
  exit 1
fi

codesign \
  --force \
  --timestamp \
  --options runtime \
  --sign "$IDENTITY" \
  "$EXECUTABLE_PATH"

codesign \
  --force \
  --timestamp \
  --options runtime \
  --sign "$IDENTITY" \
  "$APP_DIR"

codesign --verify --strict --verbose=2 "$APP_DIR"
echo "Signed app bundle: $APP_DIR"
