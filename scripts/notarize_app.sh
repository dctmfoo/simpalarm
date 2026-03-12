#!/bin/zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/SimpAlarm.app" >&2
  exit 1
fi

APP_DIR="$1"
TMP_DIR="$(mktemp -d /tmp/simpalarm-notary.XXXXXX)"
ARCHIVE_PATH="$TMP_DIR/$(basename "$APP_DIR" .app)-notary.zip"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

AUTH_ARGS=()

if [[ -n "${NOTARYTOOL_KEYCHAIN_PROFILE:-}" ]]; then
  AUTH_ARGS+=(--keychain-profile "$NOTARYTOOL_KEYCHAIN_PROFILE")
elif [[ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" && -n "${APP_STORE_CONNECT_KEY_ID:-}" ]]; then
  AUTH_ARGS+=(--key "$APP_STORE_CONNECT_API_KEY_PATH" --key-id "$APP_STORE_CONNECT_KEY_ID")
  if [[ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]]; then
    AUTH_ARGS+=(--issuer "$APP_STORE_CONNECT_ISSUER_ID")
  fi
elif [[ -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  AUTH_ARGS+=(--apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID")
else
  echo "Notarization credentials not configured." >&2
  echo "Set NOTARYTOOL_KEYCHAIN_PROFILE, or APP_STORE_CONNECT_* vars, or APPLE_ID/APPLE_APP_SPECIFIC_PASSWORD/APPLE_TEAM_ID." >&2
  exit 1
fi

ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ARCHIVE_PATH"

xcrun notarytool submit "$ARCHIVE_PATH" --wait "${AUTH_ARGS[@]}"
xcrun stapler staple "$APP_DIR"
xcrun stapler validate "$APP_DIR"

echo "Notarized app bundle: $APP_DIR"
