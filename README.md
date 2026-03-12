# SimpAlarm

SimpAlarm is a lightweight macOS menu bar alarm app inspired by the Windows SimpleAlarmApp workflow.

## Features

- Menu bar utility with quick alarm presets
- Named alarms and specific-time alarms
- Pending alarms list
- Alarm alert window with snooze and dismiss
- Custom alarm sound support
- Global shortcut support
- Local settings persistence

## Run locally

```bash
cd /Users/nags/Documents/simpalarm
./scripts/run_app_bundle.sh
```

Use the bundled app path for testing menu bar behavior instead of `swift run`.

## Distribution

Release packaging, signing, notarization, and Homebrew cask generation are documented in [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md).

## Planned install flow

```bash
brew tap dctmfoo/simpalarm
brew install --cask simpalarm
```
