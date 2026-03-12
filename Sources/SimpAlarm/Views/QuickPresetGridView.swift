import SwiftUI

struct QuickPresetGridView: View {
    let store: AlarmStore

    private let presets = [5, 10, 15, 30, 60, 120]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Presets")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(presets, id: \.self) { preset in
                    Button(action: { createAlarm(minutes: preset) }) {
                        VStack(spacing: 4) {
                            Text(label(for: preset))
                                .font(.headline)
                            Text("Quick set")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
        .padding(MenuBarMetrics.sectionPadding)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func createAlarm(minutes: Int) {
        store.createQuickAlarm(minutes: minutes)
    }

    private func label(for minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min" : "\(minutes / 60) hr"
    }
}
