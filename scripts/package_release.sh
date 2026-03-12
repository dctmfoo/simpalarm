#!/bin/zsh
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 VERSION [BUILD_NUMBER]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$1"
BUILD_NUMBER="${2:-${SIMPALARM_BUILD:-1}}"
APP_DIR="$ROOT_DIR/dist/SimpAlarm.app"
RELEASE_DIR="$ROOT_DIR/dist/releases/$VERSION"
SIGNED_APP_DIR="$RELEASE_DIR/SimpAlarm.app"
ZIP_PATH="$RELEASE_DIR/SimpAlarm-$VERSION.zip"
SHA_PATH="$RELEASE_DIR/SimpAlarm-$VERSION.sha256"

rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

CONFIGURATION=release \
SIMPALARM_VERSION="$VERSION" \
SIMPALARM_BUILD="$BUILD_NUMBER" \
"$ROOT_DIR/scripts/build_app_bundle.sh"

cp -R "$APP_DIR" "$SIGNED_APP_DIR"

if [[ -n "${DEVELOPER_ID_APP_SIGNING_IDENTITY:-}" ]]; then
  "$ROOT_DIR/scripts/sign_app.sh" "$SIGNED_APP_DIR"
else
  echo "Skipping signing because DEVELOPER_ID_APP_SIGNING_IDENTITY is not set."
fi

if [[ -n "${NOTARYTOOL_KEYCHAIN_PROFILE:-}" || -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" || -n "${APPLE_ID:-}" ]]; then
  "$ROOT_DIR/scripts/notarize_app.sh" "$SIGNED_APP_DIR"
else
  echo "Skipping notarization because no notarization credentials are configured."
fi

rm -f "$ZIP_PATH" "$SHA_PATH"
ditto -c -k --sequesterRsrc --keepParent "$SIGNED_APP_DIR" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" | awk '{print $1}' > "$SHA_PATH"

SHA256_VALUE="$(cat "$SHA_PATH")"
"$ROOT_DIR/scripts/render_cask.sh" "$VERSION" "$SHA256_VALUE"
cp "$ROOT_DIR/packaging/homebrew/Casks/simpalarm.rb" "$RELEASE_DIR/simpalarm.rb"

echo "Packaged release zip: $ZIP_PATH"
echo "SHA-256: $SHA256_VALUE"
