import WidgetKit
import SwiftUI

// MARK: - Providers
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            total: 7,
            classes: [
                Class(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        let currentDate = Date()
        let entry = ScheduleEntry(
            date: currentDate,
            total: 7,
            classes: [
                Class(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1"),
                Class(title: "Java Programming", time: "5:00 PM - 5:50 PM", slot: "A1 + TA1"),
                Class(title: "Machine Learning", time: "6:00 PM - 6:50 PM", slot: "B2 + TB2")
            ]
        )
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

struct VittyWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(hex: "#041727")
                .ignoresSafeArea()

            switch family {
            case .systemSmall:
                ScheduleSmallWidgetView(entry: entry)
            case .systemMedium:
                ScheduleMediumWidgetView(entry: entry)
                
            default:
                Text("Unsupported size")
            }
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}

struct VittyWidget: Widget {
    let kind: String = "VittyWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VittyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vitty Widget")
        .description("Widget with different designs based on size.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Helper Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF) / 255.0
        b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
struct DueProvider: TimelineProvider {
    func placeholder(in context: Context) -> DueEntry {
        DueEntry(
            date: Date(),
            assignments: [
                Assignment(title: "Quiz 1", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA", hoursLeft: "02:00 hrs left", priority: .high,category: nil),
                Assignment(title: "Digital Assignment I", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA", hoursLeft: "12:00 hrs left", priority: .medium,category: nil)
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DueEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DueEntry>) -> Void) {
        let timeline = Timeline(entries: [placeholder(in: context)], policy: .atEnd)
        completion(timeline)
    }
}


struct DueWidget: Widget {
    let kind: String = "DueWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DueProvider()) { entry in
            DueWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Due Today")
        .description("View your upcoming assignments and due dates.")
        .supportedFamilies([.systemSmall, .systemMedium,.systemLarge])
    }
}
struct DueWidgetEntryView: View {
    var entry: DueEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color(hex: "#041727")
                .ignoresSafeArea()
            
            switch family {
            case .systemSmall:
                if !entry.assignments.isEmpty {
                    DueSmallWidgetView(assignment: entry.assignments[0])
                }
            case .systemMedium:
                DueMediumWidgetView(assignments: entry.assignments)
            case .systemLarge:
                LargeDueWidgetView(assignments: entry.assignments)
            default:
                Text("Unsupported size")
            }
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}

// MARK: - Preview
#Preview("Large Due Widget", as: .systemLarge) {
    DueWidget()
} timeline: {
    DueEntry(
        date: Date(),
        assignments: [
            
            Assignment(title: "Quiz 1", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA",
                       hoursLeft: "02:00 hrs left", priority: .high, category: .dueToday),
            Assignment(title: "Digital Assignment I", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA",
                       hoursLeft: "12:00 hrs left", priority: .medium, category: .dueToday),
            
            // Upcoming
            Assignment(title: "Digital Assignment I", timeRange: "8 AM - 9 AM", subject: "Software Engineering - ETH",
                       hoursLeft: "2 days left", priority: .low, category: .upcoming),
            Assignment(title: "Digital Assignment I", timeRange: "8 AM - 9 AM", subject: "Software Engineering - ETH",
                       hoursLeft: "3 days left", priority: .low, category: .upcoming)
        ]
    )
}
