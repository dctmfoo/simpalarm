import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let store: AlarmStore

    @State private var launchAtLoginEnabled = false
    @State private var volume = 1.0
    @State private var snoozeMinutes = 5.0
    @State private var hasLoadedInitialValues = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            settingsSection("General") {
                settingRow("Launch at login") {
                    Toggle("", isOn: $launchAtLoginEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.regular)
                        .onChange(of: launchAtLoginEnabled) { _, newValue in
                            guard hasLoadedInitialValues else { return }

                            Task {
                                await store.applyLaunchAtLoginPreference(newValue)
                                launchAtLoginEnabled = store.settings.launchAtLoginEnabled
                            }
                        }
                }

                Divider()

                settingRow("Global shortcut") {
                    Text(store.settings.globalShortcutDisplay)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            settingsSection("Alarm") {
                VStack(alignment: .leading, spacing: 14) {
                    settingControlRow("Volume", value: "\(Int(volume * 100))%") {
                        Slider(value: $volume, in: 0.1...1.0)
                            .onChange(of: volume) { _, newValue in
                                guard hasLoadedInitialValues else { return }
                                store.updateAlarmVolume(newValue)
                            }
                    }

                    Divider()

                    settingControlRow("Default snooze", value: "\(Int(snoozeMinutes)) min") {
                        Slider(value: $snoozeMinutes, in: 1...15, step: 1)
                            .onChange(of: snoozeMinutes) { _, newValue in
                                guard hasLoadedInitialValues else { return }
                                store.updateDefaultSnoozeMinutes(Int(newValue))
                            }
                    }

                    Divider()

                    settingControlRow("Sound", value: store.customSoundDisplayName()) {
                        HStack {
                            Button("Choose Sound", systemImage: "music.note", action: chooseSound)
                            Button("Test", systemImage: "play.fill") {
                                store.playSoundPreview()
                            }

                            if !store.settings.customSoundPath.isEmpty {
                                Button("Use Default", systemImage: "arrow.uturn.backward") {
                                    store.resetCustomSound()
                                }
                            }

                            Spacer(minLength: 0)
                        }
                    }
                }
            }

            settingsSection("Notifications") {
                settingRow("Status") {
                    Text(store.notificationStatusLabel())
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Button("Refresh Notification Status", systemImage: "bell.badge") {
                        store.refreshNotificationStatus()
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(24)
        .frame(width: 520, height: 480, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            launchAtLoginEnabled = store.settings.launchAtLoginEnabled
            volume = store.settings.alarmVolume
            snoozeMinutes = Double(store.settings.defaultSnoozeMinutes)
            hasLoadedInitialValues = true
        }
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            GroupBox {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(16)
            }
            .controlSize(.large)
        }
    }

    private func settingRow<Accessory: View>(_ title: String, @ViewBuilder accessory: () -> Accessory) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
            Spacer(minLength: 20)
            accessory()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingControlRow<Control: View>(
        _ title: String,
        value: String,
        @ViewBuilder control: () -> Control
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                Text(title)
                Spacer(minLength: 20)
                Text(value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            control()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
