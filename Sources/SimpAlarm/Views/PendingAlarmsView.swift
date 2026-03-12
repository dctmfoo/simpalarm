import SwiftUI

struct PendingAlarmsView: View {
    let store: AlarmStore

    var body: some View {
        Group {
            if store.pendingAlarms.isEmpty {
                ContentUnavailableView(
                    "No Pending Alarms",
                    systemImage: "alarm",
                    description: Text("Create a new alarm from the menu bar or the quick composer.")
                )
            } else {
                List(store.pendingAlarms) { alarm in
                    PendingAlarmRowView(store: store, alarm: alarm)
                }
                .listStyle(.inset)
            }
        }
        .frame(minWidth: 480, minHeight: 360)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add New", systemImage: "plus", action: addNewAlarm)
            }
        }
    }

    private func addNewAlarm() {
        WindowCoordinator.shared.showNewAlarmWindow()
    }
}

#Preview {
    PendingAlarmsView(store: AlarmStore())
}
