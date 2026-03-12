import SwiftUI

struct MenuBarHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Quick Alarm", systemImage: "alarm.waves.left.and.right")
                .font(.headline.bold())

            Text("Set an alarm in seconds or open the full composer for named alarms and specific times.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MenuBarMetrics.sectionPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: 14))
    }
}
