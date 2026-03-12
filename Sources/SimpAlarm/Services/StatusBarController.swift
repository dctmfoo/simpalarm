import AppKit

@MainActor
final class StatusBarController: NSObject {
    static let shared = StatusBarController()

    private weak var store: AlarmStore?
    private var statusItem: NSStatusItem?

    func install(store: AlarmStore) {
        self.store = store

        if statusItem == nil {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            statusItem = item

            if let button = item.button {
                button.image = NSImage(
                    systemSymbolName: "alarm.waves.left.and.right",
                    accessibilityDescription: "SimpAlarm"
                )
                button.image?.isTemplate = true
            }
        }

        statusItem?.menu = makeMenu()
    }

    func refreshMenu() {
        statusItem?.menu = makeMenu()
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()

        addHeader(to: menu)
        menu.addItem(.separator())
        addPresetItems(to: menu)
        menu.addItem(.separator())
        addActionItems(to: menu)
        menu.addItem(.separator())
        addQuitItem(to: menu)

        return menu
    }

    private func addHeader(to menu: NSMenu) {
        let titleItem = NSMenuItem()
        titleItem.title = "SimpAlarm"
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        let subtitleItem = NSMenuItem()
        subtitleItem.title = "Quick alarms from your menu bar"
        subtitleItem.isEnabled = false
        menu.addItem(subtitleItem)
    }

    private func addPresetItems(to menu: NSMenu) {
        let presets = [
            (5, "Set Alarm for 5 Minutes"),
            (10, "Set Alarm for 10 Minutes"),
            (15, "Set Alarm for 15 Minutes"),
            (30, "Set Alarm for 30 Minutes"),
            (60, "Set Alarm for 1 Hour"),
            (120, "Set Alarm for 2 Hours"),
        ]

        for (minutes, title) in presets {
            let item = NSMenuItem(title: title, action: #selector(handlePreset(_:)), keyEquivalent: "")
            item.target = self
            item.tag = minutes
            menu.addItem(item)
        }
    }

    private func addActionItems(to menu: NSMenu) {
        let newAlarmItem = NSMenuItem(title: "More Options…", action: #selector(openComposer), keyEquivalent: "")
        newAlarmItem.target = self
        menu.addItem(newAlarmItem)

        let pendingCount = store?.pendingAlarms.count ?? 0
        let pendingTitle = pendingCount > 0
            ? "View Pending Alarms (\(pendingCount))"
            : "View Pending Alarms"
        let pendingItem = NSMenuItem(title: pendingTitle, action: #selector(openPendingAlarms), keyEquivalent: "")
        pendingItem.target = self
        menu.addItem(pendingItem)

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
    }

    private func addQuitItem(to menu: NSMenu) {
        let quitItem = NSMenuItem(title: "Quit SimpAlarm", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc
    private func handlePreset(_ sender: NSMenuItem) {
        store?.createQuickAlarm(minutes: sender.tag)
        refreshMenu()
    }

    @objc
    private func openComposer() {
        DispatchQueue.main.async {
            WindowCoordinator.shared.showNewAlarmWindow()
        }
    }

    @objc
    private func openPendingAlarms() {
        DispatchQueue.main.async {
            WindowCoordinator.shared.showPendingAlarmsWindow()
        }
    }

    @objc
    private func openSettings() {
        DispatchQueue.main.async {
            WindowCoordinator.shared.showSettingsWindow()
        }
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }
}
