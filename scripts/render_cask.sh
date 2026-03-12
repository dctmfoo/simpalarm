#!/bin/zsh
set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Usage: $0 VERSION SHA256 [GITHUB_OWNER] [GITHUB_REPO]" >&2
  exit 1
fi

VERSION="$1"
SHA256_VALUE="$2"
OWNER="${3:-${GITHUB_OWNER:-REPLACE_ME}}"
REPO="${4:-${GITHUB_REPO:-simpalarm}}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/packaging/homebrew/Casks"
OUTPUT_PATH="$OUTPUT_DIR/simpalarm.rb"

mkdir -p "$OUTPUT_DIR"

cat > "$OUTPUT_PATH" <<CASK
cask "simpalarm" do
  version "$VERSION"
  sha256 "$SHA256_VALUE"

  url "https://github.com/$OWNER/$REPO/releases/download/v#{version}/SimpAlarm-#{version}.zip"
  name "SimpAlarm"
  desc "Menu bar alarm app for macOS"
  homepage "https://github.com/$OWNER/$REPO"

  depends_on macos: ">= :sonoma"

  app "SimpAlarm.app"
end
CASK

echo "Rendered Homebrew cask: $OUTPUT_PATH"
