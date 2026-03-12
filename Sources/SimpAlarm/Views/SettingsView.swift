import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let store: AlarmStore

    @State private var launchAtLoginEnabled = false
    @State private var volume = 1.0
    @State private var snoozeMinutes = 5.0

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLoginEnabled)
                    .onChange(of: launchAtLoginEnabled) { _, newValue in
                        Task {
                            await store.applyLaunchAtLoginPreference(newValue)
                            launchAtLoginEnabled = store.settings.launchAtLoginEnabled
                        }
                    }

                LabeledContent("Global shortcut") {
                    Text(store.settings.globalShortcutDisplay)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Alarm") {
                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Volume") {
                        Text("\(Int(volume * 100))%")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $volume, in: 0.1...1.0)
                        .onChange(of: volume) { _, newValue in
                            store.updateAlarmVolume(newValue)
                        }
                }

                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Default snooze") {
                        Text("\(Int(snoozeMinutes)) min")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $snoozeMinutes, in: 1...15, step: 1)
                        .onChange(of: snoozeMinutes) { _, newValue in
                            store.updateDefaultSnoozeMinutes(Int(newValue))
                        }
                }

                VStack(alignment: .leading, spacing: 10) {
                    LabeledContent("Sound") {
                        Text(store.customSoundDisplayName())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    HStack {
                        Button("Choose Sound", systemImage: "music.note") {
                            chooseSound()
                        }

                        Button("Test", systemImage: "play.fill") {
                            store.playSoundPreview()
                        }

                        if !store.settings.customSoundPath.isEmpty {
                            Button("Use Default", systemImage: "arrow.uturn.backward") {
                                store.resetCustomSound()
                            }
                        }
                    }
                }
            }

            Section("Notifications") {
                LabeledContent("Status") {
                    Text(store.notificationStatusLabel())
                        .foregroundStyle(.secondary)
                }

                Button("Refresh Notification Status", systemImage: "bell.badge") {
                    store.refreshNotificationStatus()
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .task {
            launchAtLoginEnabled = store.settings.launchAtLoginEnabled
            volume = store.settings.alarmVolume
            snoozeMinutes = Double(store.settings.defaultSnoozeMinutes)
        }
    }

    private func chooseSound() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .audio,
            .mp3,
            .mpeg4Audio,
            .wav,
            .aiff,
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false

        if panel.runModal() == .OK, let selectedURL = panel.url {
            store.updateCustomSoundPath(selectedURL.path)
        }
    }
}
