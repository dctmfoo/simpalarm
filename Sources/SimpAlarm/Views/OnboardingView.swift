import SwiftUI

struct OnboardingView: View {
    let store: AlarmStore

    @State private var launchAtLoginEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Welcome to SimpAlarm", systemImage: "alarm.waves.left.and.right")
                    .font(.title.bold())

                Text("SimpAlarm lives in your menu bar so you can set quick alarms without keeping a full app window open.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 12) {
                featureRow("Quick presets from the menu bar", systemImage: "bolt.fill")
                featureRow("Global shortcut: \(store.settings.globalShortcutDisplay)", systemImage: "keyboard")
                featureRow("Named alarms, pending alarms, and snooze", systemImage: "list.bullet.rectangle")
            }

            Toggle("Launch at login", isOn: $launchAtLoginEnabled)
                .toggleStyle(.switch)

            Text("This welcome step appears only once. You can change launch-at-login later in Settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                Button("Not Now", role: .cancel, action: skip)

                Spacer()

                Button("Get Started", systemImage: "arrow.right.circle.fill", action: getStarted)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .padding(24)
        .frame(width: 420)
    }

    private func getStarted() {
        Task {
            await store.completeOnboarding(enableLaunchAtLogin: launchAtLoginEnabled)
        }
    }

    private func skip() {
        store.skipOnboarding()
    }

    private func featureRow(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
    }
}
