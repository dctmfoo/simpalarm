import AppKit
import SwiftUI

@MainActor
final class WindowCoordinator: NSObject, NSWindowDelegate {
    static let shared = WindowCoordinator()

    private weak var store: AlarmStore?
    private let hotkeyMonitor = GlobalHotkeyMonitor()

    private var newAlarmWindow: NSWindow?
    private var pendingAlarmsWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?
    private var alertWindows: [UUID: NSWindow] = [:]

    func install(store: AlarmStore) {
        self.store = store
    }

    func applicationDidFinishLaunching() {
        hotkeyMonitor.onHotkeyPressed = { [weak self] in
            self?.showNewAlarmWindow()
        }
        hotkeyMonitor.register()

        guard let store else { return }
        store.handleApplicationLaunch()

        if !store.settings.hasCompletedOnboarding {
            showOnboardingWindow()
        } else {
            deactivateIfPossible()
        }
    }

    func showNewAlarmWindow() {
        guard let store else { return }

        if let existingWindow = newAlarmWindow, isReusable(existingWindow) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = makeWindow(
            identifier: "new-alarm",
            title: "New Alarm",
            size: NSSize(width: 420, height: 560),
            isResizable: false,
            isFloating: true,
            content: NewAlarmWindowView(store: store)
        )

        newAlarmWindow = window
        present(window)
    }

    func showPendingAlarmsWindow() {
        guard let store else { return }

        if let existingWindow = pendingAlarmsWindow, isReusable(existingWindow) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = makeWindow(
            identifier: "pending-alarms",
            title: "Pending Alarms",
            size: NSSize(width: 520, height: 460),
            isResizable: true,
            isFloating: false,
            content: PendingAlarmsView(store: store)
        )

        pendingAlarmsWindow = window
        present(window)
    }

    func showSettingsWindow() {
        guard let store else { return }

        if let existingWindow = settingsWindow, isReusable(existingWindow) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = makeWindow(
            identifier: "settings",
            title: "Settings",
            size: NSSize(width: 520, height: 480),
            isResizable: false,
            isFloating: false,
            content: SettingsView(store: store)
        )

        settingsWindow = window
        present(window)
    }

    func showOnboardingWindow() {
        guard let store else { return }

        if let existingWindow = onboardingWindow, isReusable(existingWindow) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = makeWindow(
            identifier: "onboarding",
            title: "Welcome to SimpAlarm",
            size: NSSize(width: 440, height: 400),
            isResizable: false,
            isFloating: true,
            content: OnboardingView(store: store)
        )

        onboardingWindow = window
        present(window)
    }

    func closeOnboardingWindow() {
        onboardingWindow?.close()
    }

    func deactivateAfterTransientUIIfPossible() {
        deactivateIfPossible()
    }

    func showAlertWindow(for alarmID: UUID) {
        guard let store else { return }

        if let existingWindow = alertWindows[alarmID], isReusable(existingWindow) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = makeWindow(
            identifier: "alarm-\(alarmID.uuidString)",
            title: "Alarm",
            size: NSSize(width: 420, height: 300),
            isResizable: false,
            isFloating: true,
            content: AlarmAlertView(store: store, alarmID: alarmID)
        )

        alertWindows[alarmID] = window
        present(window)
    }

    func closeAlertWindow(for alarmID: UUID) {
        alertWindows[alarmID]?.close()
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        if window === newAlarmWindow {
            newAlarmWindow = nil
        } else if window === pendingAlarmsWindow {
            pendingAlarmsWindow = nil
        } else if window === settingsWindow {
            settingsWindow = nil
        } else if window === onboardingWindow {
            if let store, !store.settings.hasCompletedOnboarding {
                onboardingWindow = nil
                store.skipOnboarding(closeWindow: false)
                return
            }
            onboardingWindow = nil
        } else if let matchedAlert = alertWindows.first(where: { $0.value === window }) {
            alertWindows.removeValue(forKey: matchedAlert.key)
        }

        deactivateIfPossible()
    }

    private func makeWindow<Content: View>(
        identifier: String,
        title: String,
        size: NSSize,
        isResizable: Bool,
        isFloating: Bool,
        content: Content
    ) -> NSWindow {
        let styleMask: NSWindow.StyleMask = isResizable
            ? [.titled, .closable, .miniaturizable, .resizable]
            : [.titled, .closable, .miniaturizable]

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.identifier = NSUserInterfaceItemIdentifier(identifier)
        window.title = title
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.level = isFloating ? .floating : .normal
        window.toolbarStyle = .automatic
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.standardWindowButton(.zoomButton)?.isHidden = !isResizable
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        if !isResizable {
            window.contentMinSize = size
            window.contentMaxSize = size
            window.setContentSize(size)
        }

        let hostingController = NSHostingController(
            rootView: content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        )
        hostingController.view.frame = NSRect(origin: .zero, size: size)
        window.contentViewController = hostingController

        return window
    }

    private func present(_ window: NSWindow) {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func deactivateIfPossible() {
        let visibleManagedWindows = [
            newAlarmWindow,
            pendingAlarmsWindow,
            settingsWindow,
            onboardingWindow,
        ]
        .compactMap { $0 }
        .contains { $0.isVisible }

        let hasVisibleAlert = alertWindows.values.contains { $0.isVisible }

        if !visibleManagedWindows && !hasVisibleAlert {
            NSApp.deactivate()
        }
    }

    private func isReusable(_ window: NSWindow) -> Bool {
        guard window.isVisible else { return false }
        guard let controller = window.contentViewController else {
            window.close()
            return false
        }

        if controller.view.superview == nil && window.contentView == nil {
            window.close()
            return false
        }

        return true
    }
}
