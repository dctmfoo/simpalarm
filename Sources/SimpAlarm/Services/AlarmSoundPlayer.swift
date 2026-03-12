import AppKit
import AVFoundation
import Foundation

@MainActor
final class AlarmSoundPlayer {
    private var players: [UUID: AVAudioPlayer] = [:]
    private var previewPlayer: AVAudioPlayer?

    func playLoop(for alarmID: UUID, volume: Double, customSoundPath: String) {
        stop(for: alarmID)

        guard let soundURL = resolvedSoundURL(customSoundPath: customSoundPath) else {
            NSSound.beep()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.volume = Float(max(0.0, min(volume, 1.0)))
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            players[alarmID] = player
        } catch {
            NSSound.beep()
        }
    }

    func playPreview(volume: Double, customSoundPath: String) {
        stopPreview()

        guard let soundURL = resolvedSoundURL(customSoundPath: customSoundPath) else {
            NSSound.beep()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.volume = Float(max(0.0, min(volume, 1.0)))
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
            previewPlayer = player
        } catch {
            NSSound.beep()
        }
    }

    func updateVolume(_ volume: Double) {
        let clampedVolume = Float(max(0.0, min(volume, 1.0)))
        for player in players.values {
            player.volume = clampedVolume
        }
        previewPlayer?.volume = clampedVolume
    }

    func stop(for alarmID: UUID) {
        guard let player = players.removeValue(forKey: alarmID) else { return }
        player.stop()
    }

    func stopAll() {
        let alarmIDs = Array(players.keys)
        for alarmID in alarmIDs {
            stop(for: alarmID)
        }
    }

    func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
    }

    private func resolvedSoundURL(customSoundPath: String) -> URL? {
        if !customSoundPath.isEmpty {
            let fileURL = URL(fileURLWithPath: customSoundPath)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }

        if let appResourceURL = Bundle.main.resourceURL?.appending(path: "alarm.mp3", directoryHint: .notDirectory),
           FileManager.default.fileExists(atPath: appResourceURL.path) {
            return appResourceURL
        }

        return Bundle.module.url(forResource: "alarm", withExtension: "mp3")
    }
}
