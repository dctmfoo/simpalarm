import SwiftUI

struct AlarmComposerFormView: View {
    let store: AlarmStore

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedMode: AlarmComposerMode = .minutesFromNow
    @State private var minutesFromNow = 30
    @State private var specificTime = Date.now

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Alarm Name")
                    .font(.headline)

                TextField("Optional name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            Picker("Schedule Type", selection: $selectedMode) {
                Text("Minutes from now").tag(AlarmComposerMode.minutesFromNow)
                Text("Specific time").tag(AlarmComposerMode.specificTime)
            }
            .pickerStyle(.segmented)

            if selectedMode == .minutesFromNow {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Minutes")
                        .font(.headline)

                    TextField("Minutes", value: $minutesFromNow, format: .number)
                        .textFieldStyle(.roundedBorder)

                    Text("Alarm will ring in \(minutesFromNow) minute(s).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.headline)

                    DatePicker(
                        "Specific time",
                        selection: $specificTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.field)
                    .labelsHidden()

                    Text("If that time has already passed today, the alarm will roll to tomorrow.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button("Cancel", role: .cancel, action: dismiss.callAsFunction)
                Spacer()
                Button("Set Alarm", systemImage: "checkmark.circle.fill", action: setAlarm)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(18)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func setAlarm() {
        switch selectedMode {
        case .minutesFromNow:
            let safeMinutes = max(1, minutesFromNow)
            store.createAlarm(
                name: name,
                scheduledAt: Date.now.addingTimeInterval(Double(safeMinutes) * 60)
            )
        case .specificTime:
            store.createAlarm(
                name: name,
                scheduledAt: nextOccurrence(for: specificTime)
            )
        }

        dismiss()
    }

    private func nextOccurrence(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let now = Date.now

        let today = calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: 0,
            of: now
        ) ?? now

        if today > now {
            return today
        }

        return calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }
}
