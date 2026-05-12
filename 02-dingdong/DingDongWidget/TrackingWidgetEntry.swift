import WidgetKit
import Foundation

struct TrackingEntry: TimelineEntry {
    let date: Date
    let tasks: [TrackingWidgetData]
}

struct TrackingWidgetData: Identifiable {
    let id: UUID
    let doctorName: String
    let clinicRoom: String
    let hospitalName: String
    let currentNumber: Int
    let userNumber: Int?
    let remaining: Int?
    let updatedAt: Date

    static func from(_ task: TrackingTask) -> TrackingWidgetData {
        TrackingWidgetData(
            id: task.id,
            doctorName: task.doctorName,
            clinicRoom: task.clinicRoom,
            hospitalName: task.hospitalName,
            currentNumber: task.currentNumber,
            userNumber: task.userNumber,
            remaining: task.remaining,
            updatedAt: task.lastUpdated
        )
    }

    static let placeholder = TrackingWidgetData(
        id: UUID(),
        doctorName: "王小明",
        clinicRoom: "03 診",
        hospitalName: "台大醫院",
        currentNumber: 42,
        userNumber: 55,
        remaining: 13,
        updatedAt: Date()
    )
}
