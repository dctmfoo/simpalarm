# SimpAlarm Distribution

This repo can produce a Homebrew-installable macOS app without requiring an Xcode project.

## What gets shipped

- `dist/SimpAlarm.app`: the current locally built app bundle
- `dist/releases/<version>/SimpAlarm-<version>.zip`: the versioned release artifact
- `dist/releases/<version>/SimpAlarm.app`: the signed and stapled app bundle used to create the zip
- `dist/releases/<version>/SimpAlarm-<version>.sha256`: checksum for the Homebrew cask
- `dist/releases/<version>/simpalarm.rb`: generated Homebrew cask file

## Local release flow

Build an unsigned local release:

```bash
cd simpalarm
chmod +x scripts/*.sh
./scripts/package_release.sh 0.1.0
```

That generates a zip, checksum, and cask file under `dist/releases/0.1.0`.

## Signing

To sign locally, export the Developer ID identity before running `package_release.sh`:

```bash
export DEVELOPER_ID_APP_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)"
./scripts/package_release.sh 0.1.0
```

## Notarization

You can notarize with either a saved notarytool keychain profile or Apple ID credentials.

Using a stored keychain profile:

```bash
export NOTARYTOOL_KEYCHAIN_PROFILE="simpalarm-notary"
./scripts/package_release.sh 0.1.0
```

Using Apple ID credentials directly:

```bash
export APPLE_ID="you@example.com"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export APPLE_TEAM_ID="TEAMID"
./scripts/package_release.sh 0.1.0
```

## Homebrew tap flow

SimpAlarm should be distributed as a Homebrew cask.

Create a tap once:

```bash
brew tap-new dctmfoo/homebrew-simpalarm
```

Then copy the generated cask into the tap repo:

```bash
cp dist/releases/0.1.0/simpalarm.rb /path/to/homebrew-simpalarm/Casks/simpalarm.rb
```

Commit and push the tap:

```bash
cd /path/to/homebrew-simpalarm
git add Casks/simpalarm.rb
git commit -m "Add SimpAlarm 0.1.0"
git push
```

Friends can then install with:

```bash
brew tap dctmfoo/simpalarm
brew install --cask simpalarm
```

## GitHub Actions secrets

The included workflow expects these repository secrets:

- `DEVELOPER_ID_APP_CERT_P12_BASE64`: base64-encoded `.p12` certificate
- `DEVELOPER_ID_APP_CERT_PASSWORD`: password for the `.p12`
- `DEVELOPER_ID_APP_SIGNING_IDENTITY`: full Developer ID Application identity name
- `BUILD_KEYCHAIN_PASSWORD`: temporary CI keychain password
- `APPLE_ID`: Apple ID used for notarization
- `APPLE_APP_SPECIFIC_PASSWORD`: app-specific password for notarytool
- `APPLE_TEAM_ID`: Apple Developer team ID

## GitHub release flow

After secrets are configured, create a tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release workflow will:

- build the app bundle
- sign it
- notarize it
- staple it
- package a release zip
- generate a Homebrew cask
- upload both to the GitHub Release
