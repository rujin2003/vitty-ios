import WidgetKit
import SwiftUI


struct DueProvider: TimelineProvider {
    func placeholder(in context: Context) -> DueEntry {
        DueEntry(date: Date(), title: "Quiz 1", timeRange: "8 AM - 9 AM", subject: "Java Programming", hoursLeft: "02:00 hrs left")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DueEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DueEntry>) -> Void) {
        let timeline = Timeline(entries: [placeholder(in: context)], policy: .atEnd)
        completion(timeline)
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let entry = ScheduleEntry(date: Date(), progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        var entries: [ScheduleEntry] = []
        let currentDate = Date()
        
        let entry = ScheduleEntry(
            date: currentDate,
            progress: 6,
            total: 7,
            nextClass: "Software Engineering",
            nextClassTime: "4:00 PM - 4:50 PM"
        )
        entries.append(entry)
        
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
struct ScheduleEntry: TimelineEntry {
    let date: Date
    let progress: Int
    let total: Int
    let nextClass: String
    let nextClassTime: String
}

struct DueEntry: TimelineEntry {
    let date: Date
    let title: String
    let timeRange: String
    let subject: String
    let hoursLeft: String
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
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                Text("Unsupported size")
            }
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}



struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
           
            VStack {
                WidgetTitle(title: "Schedule", fontSize: 22.0)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color(hex: "#BBE7FF").opacity(0.3), lineWidth: 10)
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.progress) / CGFloat(entry.total))
                        .stroke(
                            Color(hex: "#BBE7FF"),
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(entry.progress) / \(entry.total)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.leading)
            
           
            VStack(alignment: .leading) {
                Spacer()
                
                Text("Up Next")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                Text(entry.nextClass)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.nextClassTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#BBE7FF"))
                
                Spacer()
            }
            .padding(.trailing)
        }
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            WidgetTitle(title: "Schedule", fontSize: 30.0)
            
            HStack {
                // Progress circle
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color(hex: "#BBE7FF").opacity(0.3), lineWidth: 15)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.progress) / CGFloat(entry.total))
                        .stroke(
                            Color(hex: "#BBE7FF"),
                            style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(entry.progress) / \(entry.total)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
            
                VStack(alignment: .leading) {
                    Text("Up Next")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(entry.nextClass)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.nextClassTime)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#BBE7FF"))
                }
            }
            
            Spacer()
            
          
            Text("Coming Up")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 10) {
                ScheduleRow(className: "Math", time: "5:00 PM - 5:50 PM")
                ScheduleRow(className: "Physics", time: "6:00 PM - 6:50 PM")
            }
            
            Spacer()
        }
        .padding()
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

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

// MARK: - Widget Entry Views
struct ScheduleWidgetEntryView: View {
    var entry: ScheduleEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color(hex: "#041727")
                .ignoresSafeArea()
            
            switch family {
            case .systemSmall:
                ScheduleSmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                Text("Unsupported size")
            }
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
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
        .supportedFamilies([.systemSmall])
    }
}

struct DueWidgetEntryView: View {
    var entry: DueEntry
    
    var body: some View {
        ZStack {
            Color(hex: "#041727")
                .ignoresSafeArea()
            
            DueSmallWidgetView(entry: entry)
        }
        .containerBackground(for: .widget) { Color(hex: "#041727") }
    }
}



#Preview(as: .systemSmall) {
    VittyWidget()
} timeline: {
    ScheduleEntry(date: .now, progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
}
