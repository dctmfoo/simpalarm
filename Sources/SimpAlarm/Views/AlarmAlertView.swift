import SwiftUI

struct AlarmAlertView: View {
    let store: AlarmStore
    let alarmID: UUID

    private var alarm: Alarm? {
        store.alarm(for: alarmID)
    }

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.system(size: 54))
                .foregroundStyle(.red)
                .symbolEffect(.pulse, options: .repeating)

            Text("Time's Up")
                .font(.largeTitle.weight(.bold))
                .fontDesign(.rounded)

            if let alarm {
                Text(alarm.name)
                    .font(.title3.weight(.semibold))

                Text(alarm.scheduledAt.formatted(date: .omitted, time: .shortened))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button("Snooze \(store.settings.defaultSnoozeMinutes) min", systemImage: "moon.zzz.fill", action: snooze)
                    .buttonStyle(.bordered)

                Button("Dismiss", systemImage: "checkmark.circle.fill", action: dismiss)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(minWidth: 360)
        .background(
            LinearGradient(
                colors: [.red.opacity(0.10), .orange.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func snooze() {
        store.snoozeAlarm(id: alarmID)
    }

    private func dismiss() {
        store.dismissAlarm(id: alarmID)
    }
}
