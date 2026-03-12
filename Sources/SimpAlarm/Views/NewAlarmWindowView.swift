import SwiftUI

struct NewAlarmWindowView: View {
    let store: AlarmStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                NewAlarmHeaderView()
                QuickPresetStripView(store: store)
                AlarmComposerFormView(store: store)
            }
            .padding(20)
        }
        .frame(minWidth: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    NewAlarmWindowView(store: AlarmStore())
}
