import Foundation

struct AppSettings: Codable {
    var hasCompletedOnboarding = false
    var launchAtLoginEnabled = false
    var alarmVolume = 1.0
    var defaultSnoozeMinutes = 5
    var globalShortcutDisplay = "⌃⇧B"
    var customSoundPath = ""
}
