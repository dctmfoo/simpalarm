import Foundation

struct Alarm: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var scheduledAt: Date
    var snoozeCount: Int
    var state: AlarmState

    init(
        id: UUID = UUID(),
        name: String,
        scheduledAt: Date,
        snoozeCount: Int = 0,
        state: AlarmState = .pending
    ) {
        self.id = id
        self.name = name
        self.scheduledAt = scheduledAt
        self.snoozeCount = snoozeCount
        self.state = state
    }
}
