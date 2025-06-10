import WidgetKit
import SwiftUI
import SwiftData


// MARK: - Providers
    struct Provider: TimelineProvider {
        
        
        @MainActor @preconcurrency
        func placeholder(in context: Context) -> ScheduleEntry {
            let timeTable = getTimetable()
            let parsed = parseTimeTable(timeTable: timeTable)

            return ScheduleEntry(
                date: parsed.firstLectureDate,
                total: parsed.count,
                classes: parsed.classes
            )
        }

        // GET TIME TABLE FUNCTION
        @MainActor
        private func getTimetable() -> TimeTable {
            guard let modelContainer  = try? ModelContainer(for:TimeTable.self)else{
                return TimeTable(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: [])
            }
            print("stage 1: this timetable is sucessfull")
            
            let descriptor = FetchDescriptor<TimeTable>()
            print("stage 2: this timetable is sucessfull")
            
            let timeTable = try? modelContainer.mainContext.fetch(descriptor)
            print("stage 3: this timetable is sucessfull")
            print("\(String(describing: timeTable))")
            return timeTable?[0] ?? TimeTable(monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: [])
          
            
        }

        @MainActor @preconcurrency func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
            completion(placeholder(in: context))
        }
        
        func parseTimeTable(timeTable: TimeTable) -> (classes: [Class], firstLectureDate: Date, count: Int) {
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let weekday = calendar.component(.weekday, from: Date()) // Sunday = 1
            let lecturesForToday: [Lecture]

            switch weekday {
                case 2: lecturesForToday = timeTable.monday
                case 3: lecturesForToday = timeTable.tuesday
                case 4: lecturesForToday = timeTable.wednesday
                case 5: lecturesForToday = timeTable.thursday
                case 6: lecturesForToday = timeTable.friday
                case 7: lecturesForToday = timeTable.saturday
                case 1: lecturesForToday = timeTable.sunday
                default: lecturesForToday = []
            }

            let classes = lecturesForToday.map {
                Class(title: $0.name, time: "\($0.startTime) - \($0.endTime)", slot: $0.slot)
            }

            // Convert first lecture startTime to Date (today + time)
            let today = calendar.startOfDay(for: Date())
            let firstTime = lecturesForToday.first?.startTime ?? "00:00"
            let components = formatter.date(from: firstTime).flatMap { calendar.date(bySettingHour: calendar.component(.hour, from: $0), minute: calendar.component(.minute, from: $0), second: 0, of: today) } ?? Date()

            return (classes, components, lecturesForToday.count)
        }


        
        @MainActor @preconcurrency
        func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
            let timeTable = getTimetable()
            let parsed = parseTimeTable(timeTable: timeTable)
            
       
            let entry =  ScheduleEntry(
                date: parsed.firstLectureDate,
                total: parsed.count,
                classes: parsed.classes
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
