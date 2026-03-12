import SwiftUI

struct NewAlarmHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("New Alarm")
                .font(.largeTitle.weight(.bold))
                .fontDesign(.rounded)

            Text("Use quick presets for speed or set a named alarm for an exact time.")
                .foregroundStyle(.secondary)
        }
    }
}
