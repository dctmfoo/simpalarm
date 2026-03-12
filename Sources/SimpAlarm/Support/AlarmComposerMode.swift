import Foundation

enum AlarmComposerMode: String, CaseIterable, Identifiable {
    case minutesFromNow
    case specificTime

    var id: String { rawValue }
}
