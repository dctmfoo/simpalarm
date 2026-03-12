import Foundation

struct SettingsStore {
    private let fileManager = FileManager.default

    func load() -> AppSettings {
        guard
            let fileURL = settingsFileURL(),
            let data = try? Data(contentsOf: fileURL),
            let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
        else {
            return AppSettings()
        }

        return settings
    }

    func save(_ settings: AppSettings) {
        guard let fileURL = settingsFileURL() else { return }

        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save settings: \(error)")
        }
    }

    private func settingsFileURL() -> URL? {
        do {
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let directoryURL = appSupportURL.appending(path: "SimpAlarm", directoryHint: .isDirectory)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            return directoryURL.appending(path: "settings.json", directoryHint: .notDirectory)
        } catch {
            assertionFailure("Failed to resolve settings path: \(error)")
            return nil
        }
    }
}
