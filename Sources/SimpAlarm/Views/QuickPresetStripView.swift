import SwiftUI

struct QuickPresetStripView: View {
    let store: AlarmStore

    private let presets = [5, 10, 15, 30, 60, 120]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Presets")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(presets, id: \.self) { preset in
                    Button(label(for: preset), action: { createAlarm(minutes: preset) })
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 18))
    }

    private func createAlarm(minutes: Int) {
        store.createQuickAlarm(minutes: minutes)
    }

    private func label(for minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min" : "\(minutes / 60) hour"
    }
}
