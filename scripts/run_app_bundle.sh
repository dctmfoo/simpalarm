#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/SimpAlarm.app"
BUILD_PATH_PATTERN="$ROOT_DIR/.build/"

pkill -f "$BUILD_PATH_PATTERN" || true
pkill -x 'SimpAlarm' || true
perl -e 'unlink q{/tmp/simpalarm.lock};'

"$ROOT_DIR/scripts/build_app_bundle.sh"
open "$APP_DIR"
