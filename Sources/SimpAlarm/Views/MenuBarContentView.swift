import SwiftUI

struct MenuBarContentView: View {
    let store: AlarmStore

    var body: some View {
        VStack(alignment: .leading, spacing: MenuBarMetrics.sectionSpacing) {
            MenuBarHeaderView()
            QuickPresetGridView(store: store)
            MenuBarActionsView(store: store)
        }
        .padding(MenuBarMetrics.contentPadding)
        .frame(width: MenuBarMetrics.popoverWidth)
    }
}

#Preview {
    MenuBarContentView(store: AlarmStore())
}
