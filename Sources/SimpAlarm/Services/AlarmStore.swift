import AppKit
import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class AlarmStore {
    var alarms: [Alarm]
    var settings: AppSettings
    var notificationStatus: UNAuthorizationStatus

    @ObservationIgnored private let settingsStore = SettingsStore()
    @ObservationIgnored private let notificationManager = NotificationManager()
    @ObservationIgnored private let launchAtLoginManager = LaunchAtLoginManager()
    @ObservationIgnored private let soundPlayer = AlarmSoundPlayer()
    @ObservationIgnored private var scheduledTasks: [UUID: Task<Void, Never>] = [:]

    init() {
        settings = settingsStore.load()
        alarms = []
        notificationStatus = .notDetermined
    }

    var pendingAlarms: [Alarm] {
        alarms
            .filter { $0.state == .pending }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func handleApplicationLaunch() {
        soundPlayer.updateVolume(settings.alarmVolume)
        let launchAtLoginEnabled = launchAtLoginManager.currentEnabledState()
        if settings.launchAtLoginEnabled != launchAtLoginEnabled {
            settings.launchAtLoginEnabled = launchAtLoginEnabled
            persistSettings()
        }

        Task {
            notificationStatus = await notificationManager.currentStatus()
        }
    }

    func createQuickAlarm(minutes: Int) {
        let descriptor = minutes < 60 ? "\(minutes) minute alarm" : "\(minutes / 60) hour alarm"
        createAlarm(name: descriptor, scheduledAt: Date.now.addingTimeInterval(Double(minutes) * 60))
    }

    func createAlarm(name: String, scheduledAt: Date) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? "Alarm" : trimmedName

        let alarm = Alarm(
            name: resolvedName,
            scheduledAt: scheduledAt,
            snoozeCount: 0,
            state: .pending
        )

        alarms.append(alarm)
        alarms.sort { $0.scheduledAt < $1.scheduledAt }
        schedule(alarm)
        StatusBarController.shared.refreshMenu()

        Task {
            await notificationManager.scheduleNotification(for: alarm)
        }
    }

    func snoozeAlarm(id: UUID) {
        guard let alarmIndex = alarms.firstIndex(where: { $0.id == id }) else { return }

        soundPlayer.stop(for: id)
        WindowCoordinator.shared.closeAlertWindow(for: id)
        Task {
            await notificationManager.cancelNotification(for: id)
        }

        alarms[alarmIndex].state = .pending
        alarms[alarmIndex].snoozeCount += 1
        alarms[alarmIndex].scheduledAt = Date.now.addingTimeInterval(Double(settings.defaultSnoozeMinutes) * 60)

        schedule(alarms[alarmIndex])
        StatusBarController.shared.refreshMenu()

        Task {
            await notificationManager.scheduleNotification(for: alarms[alarmIndex])
        }
    }

    func dismissAlarm(id: UUID) {
        cancelScheduledTask(for: id)
        soundPlayer.stop(for: id)
        WindowCoordinator.shared.closeAlertWindow(for: id)
        Task {
            await notificationManager.cancelNotification(for: id)
        }
        alarms.removeAll { $0.id == id }
        StatusBarController.shared.refreshMenu()
    }

    func updateAlarmVolume(_ volume: Double) {
        settings.alarmVolume = max(0.0, min(volume, 1.0))
        soundPlayer.updateVolume(settings.alarmVolume)
        persistSettings()
    }

    func updateDefaultSnoozeMinutes(_ minutes: Int) {
        settings.defaultSnoozeMinutes = max(1, minutes)
        persistSettings()
    }

    func updateCustomSoundPath(_ path: String) {
        settings.customSoundPath = path
        persistSettings()
    }

    func resetCustomSound() {
        settings.customSoundPath = ""
        persistSettings()
    }

    func playSoundPreview() {
        soundPlayer.playPreview(
            volume: settings.alarmVolume,
            customSoundPath: settings.customSoundPath
        )
    }

    func customSoundDisplayName() -> String {
        if settings.customSoundPath.isEmpty {
            return "Default alarm.mp3"
        }

        return URL(fileURLWithPath: settings.customSoundPath).lastPathComponent
    }

    func applyLaunchAtLoginPreference(_ isEnabled: Bool) async {
        do {
            try launchAtLoginManager.setEnabled(isEnabled)
        } catch {
            settings.launchAtLoginEnabled = launchAtLoginManager.currentEnabledState()
            persistSettings()
            return
        }

        settings.launchAtLoginEnabled = launchAtLoginManager.currentEnabledState()
        persistSettings()
    }

    func completeOnboarding(enableLaunchAtLogin: Bool) async {
        settings.hasCompletedOnboarding = true
        persistSettings()

        notificationStatus = await notificationManager.requestAuthorizationIfNeeded()
        await applyLaunchAtLoginPreference(enableLaunchAtLogin)

        WindowCoordinator.shared.closeOnboardingWindow()
        WindowCoordinator.shared.showNewAlarmWindow()
    }

    func skipOnboarding(closeWindow: Bool = true) {
        settings.hasCompletedOnboarding = true
        persistSettings()
        if closeWindow {
            WindowCoordinator.shared.closeOnboardingWindow()
        }
        WindowCoordinator.shared.deactivateAfterTransientUIIfPossible()
    }

    func refreshNotificationStatus() {
        Task {
            notificationStatus = await notificationManager.currentStatus()
        }
    }

    func alarm(for id: UUID) -> Alarm? {
        alarms.first { $0.id == id }
    }

    func formattedTriggerTime(for alarm: Alarm) -> String {
        alarm.scheduledAt.formatted(date: .abbreviated, time: .shortened)
    }

    func notificationStatusLabel() -> String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            "Enabled"
        case .denied:
            "Denied"
        case .notDetermined:
            "Not requested"
        @unknown default:
            "Unknown"
        }
    }

    private func schedule(_ alarm: Alarm) {
        cancelScheduledTask(for: alarm.id)

        let delay = max(0, alarm.scheduledAt.timeIntervalSinceNow)
        scheduledTasks[alarm.id] = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: .seconds(delay))
            } catch {
                return
            }

            self.triggerAlarm(id: alarm.id)
        }
    }

    private func cancelScheduledTask(for alarmID: UUID) {
        scheduledTasks.removeValue(forKey: alarmID)?.cancel()
    }

    private func triggerAlarm(id: UUID) {
        guard let alarmIndex = alarms.firstIndex(where: { $0.id == id }) else { return }
        alarms[alarmIndex].state = .ringing
        soundPlayer.playLoop(
            for: id,
            volume: settings.alarmVolume,
            customSoundPath: settings.customSoundPath
        )
        WindowCoordinator.shared.showAlertWindow(for: id)
    }

    private func persistSettings() {
        settingsStore.save(settings)
    }
}
