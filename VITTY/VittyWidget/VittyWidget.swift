import WidgetKit
import SwiftUI
import SwiftData


struct Provider: TimelineProvider {
    
    private func getSharedContainer() -> ModelContainer? {
          let appGroupContainerID = "group.com.gdscvit.vittyioswidget"
          let config = ModelConfiguration(
            appGroupContainerID)
        
          return try? ModelContainer(for: TimeTable.self, configurations: config)
      }
    
    private func parseTimeString(_ timeString: String) -> Date? {
           let formatter = DateFormatter()
           formatter.dateFormat = "h:mm a"
           
           // Clean the time string (remove extra spaces, etc.)
           let cleanedTime = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
           
           if let time = formatter.date(from: cleanedTime) {
               // Combine with today's date
               let calendar = Calendar.current
               let now = Date()
               let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
               return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                  minute: timeComponents.minute ?? 0,
                                  second: 0,
                                  of: now)
           }
           return nil
       }
       
    private func fetchTodaysLectures() -> [Classes] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        // Get current day
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        _ = formatter.string(from: Date())
        
        // Fetch timetable
        let descriptor = FetchDescriptor<TimeTable>()
        guard let timetable = try? context.fetch(descriptor).first else {
            return []
        }
       return  timetable.classesFor(date: Date())
       
    }
    
    
          
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            total: 7,
            classes: [
                Classes(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1")
            ], completed: 2
        )
    }
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let lectures = fetchTodaysLectures()
        
        completion(ScheduleEntry(date: Date(), total: lectures.count, classes: lectures, completed: 4))
    }
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        
        let lectures = fetchTodaysLectures()
        let completed = calculateCompletedClasses(lectures)
        let entry = ScheduleEntry(date: Date(), total: lectures.count, classes: lectures,completed: completed)
        
       

        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh ?? Date()))
        completion(timeline)
    }
    private func calculateCompletedClasses(_ classes: [Classes]) -> Int {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return classes.filter { classItem in
            let timeComponents = classItem.time.components(separatedBy: " - ")
            guard timeComponents.count == 2,
                  let endTime = dateFormatter.date(from: timeComponents[1]) else {
                return false
            }

            // Set today's date with class end time
            let calendar = Calendar.current
            let endTimeToday = calendar.date(
                bySettingHour: calendar.component(.hour, from: endTime),
                minute: calendar.component(.minute, from: endTime),
                second: 0,
                of: now
            )

            guard let endTimeTodayUnwrapped = endTimeToday else { return false }

            return now > endTimeTodayUnwrapped
        }.count
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

