import SwiftUI
import WidgetKit

struct TrackingWidgetView: View {
    let entry: TrackingEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.tasks.isEmpty {
            emptyView
        } else {
            switch family {
            case .systemSmall:  smallView(task: entry.tasks[0])
            case .systemMedium: mediumView
            default:            smallView(task: entry.tasks[0])
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("無追蹤任務")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill, for: .widget)
    }

    private func smallView(task: TrackingWidgetData) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.doctorName)
                .font(.caption.bold())
                .lineLimit(1)
            Text("\(task.hospitalName) \(task.clinicRoom)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Text("#\(task.currentNumber)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.114, green: 0.733, blue: 0.267))

            if let remaining = task.remaining {
                Text("還差 \(remaining) 號")
                    .font(.caption2)
                    .foregroundStyle(remaining <= 3 ? .red : .secondary)
            }

            Text(task.updatedAt.relativeString)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .containerBackground(.fill, for: .widget)
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.tasks.prefix(3)) { task in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.doctorName)
                            .font(.caption.bold())
                            .lineLimit(1)
                        Text(task.clinicRoom)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("#\(task.currentNumber)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color(red: 0.114, green: 0.733, blue: 0.267))
                        if let remaining = task.remaining {
                            Text("差 \(remaining) 號")
                                .font(.caption2)
                                .foregroundStyle(remaining <= 3 ? .red : .secondary)
                        }
                    }
                }
                if task.id != entry.tasks.prefix(3).last?.id {
                    Divider()
                }
            }
        }
        .padding(14)
        .containerBackground(.fill, for: .widget)
    }
}
