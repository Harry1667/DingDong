import WidgetKit
import SwiftUI

struct TrackingProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrackingEntry {
        TrackingEntry(date: Date(), tasks: [.placeholder])
    }

    func getSnapshot(in context: Context, completion: @escaping (TrackingEntry) -> Void) {
        let tasks = loadTasks()
        completion(TrackingEntry(date: Date(), tasks: tasks))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrackingEntry>) -> Void) {
        let tasks = loadTasks()
        let entry = TrackingEntry(date: Date(), tasks: tasks)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadTasks() -> [TrackingWidgetData] {
        guard let data = UserDefaults(suiteName: "group.com.ajz.dingdong")?
            .data(forKey: "tracking_tasks"),
              let tasks = try? JSONDecoder().decode([TrackingTask].self, from: data) else {
            return []
        }
        return tasks
            .filter { $0.status == .active }
            .map { TrackingWidgetData.from($0) }
    }
}

struct TrackingWidget: Widget {
    let kind = "TrackingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrackingProvider()) { entry in
            TrackingWidgetView(entry: entry)
        }
        .configurationDisplayName("候診追蹤")
        .description("即時顯示您的候診進度")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
