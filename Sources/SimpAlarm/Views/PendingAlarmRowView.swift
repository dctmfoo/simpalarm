import SwiftUI

struct PendingAlarmRowView: View {
    let store: AlarmStore
    let alarm: Alarm

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "alarm.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.name)
                    .font(.headline)

                Text(store.formattedTriggerTime(for: alarm))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if alarm.snoozeCount > 0 {
                    Text("Snoozed \(alarm.snoozeCount) time(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Delete", systemImage: "trash", role: .destructive) {
                store.dismissAlarm(id: alarm.id)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}
