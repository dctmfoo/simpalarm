import AppKit
import SwiftUI

struct MenuBarActionsView: View {
    let store: AlarmStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Actions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: openComposer) {
                Label("More Options", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: openPending) {
                Label("View Pending Alarms", systemImage: "list.bullet.rectangle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: openSettings) {
                Label("Settings", systemImage: "gearshape")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            Button(role: .destructive, action: quitApp) {
                Label("Quit", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .padding(MenuBarMetrics.sectionPadding)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func openComposer() {
        WindowCoordinator.shared.showNewAlarmWindow()
    }

    private func openPending() {
        WindowCoordinator.shared.showPendingAlarmsWindow()
    }

    private func openSettings() {
        WindowCoordinator.shared.showSettingsWindow()
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}
