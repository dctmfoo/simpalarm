import Foundation
@preconcurrency import UserNotifications

actor NotificationManager {
    private var center: UNUserNotificationCenter? {
        guard Bundle.main.bundleURL.pathExtension == "app" else { return nil }
        return UNUserNotificationCenter.current()
    }

    func currentStatus() async -> UNAuthorizationStatus {
        guard let center else { return .notDetermined }
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func requestAuthorizationIfNeeded() async -> UNAuthorizationStatus {
        guard let center else { return .notDetermined }
        let current = await currentStatus()
        guard current == .notDetermined else { return current }

        do {
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return .denied
        }

        return await currentStatus()
    }

    func scheduleNotification(for alarm: Alarm) async {
        guard let center else { return }

        let content = UNMutableNotificationContent()
        content.title = alarm.name.isEmpty ? "Alarm" : alarm.name
        content.body = "Time's up."
        content.sound = .default

        let interval = max(1, alarm.scheduledAt.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelNotification(for alarmID: UUID) {
        guard let center else { return }
        center.removePendingNotificationRequests(withIdentifiers: [alarmID.uuidString])
        center.removeDeliveredNotifications(withIdentifiers: [alarmID.uuidString])
    }
}
