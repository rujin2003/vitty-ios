import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        let entry = SimpleEntry(
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let progress: Int
    let total: Int
    let nextClass: String
    let nextClassTime: String
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
                SmallWidgetView(entry: entry)
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

struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            WidgetTitle(title: "Schedule", fontSize: 12.0)
            
            Spacer().frame(height: 15)
            
         
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color(hex: "#BBE7FF").opacity(0.3), lineWidth: 12)
                    .frame(width: 45, height: 45)
                
                Circle()
                    .trim(from: 0, to: CGFloat(entry.progress) / CGFloat(entry.total))
                    .stroke(
                        Color(hex: "#BBE7FF"),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(-90))
                
                Text("\(entry.progress) / \(entry.total)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 20)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Up Next")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                
                Text(entry.nextClass)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.nextClassTime)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#BBE7FF"))
            }
            
            Spacer()
        }
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            // Left side with progress circle
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
            
            // Right side with class info
            VStack(alignment: .leading) {
                Spacer()
                
                Text("Up Next")
                    .font(.system(size: 24, weight: .medium))  // Reduced weight
                    .foregroundColor(.white)
                
                Text(entry.nextClass)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.nextClassTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#BBE7FF"))  // Changed to accent color
                
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
                
                // Class info
                VStack(alignment: .leading) {
                    Text("Up Next")
                        .font(.system(size: 32, weight: .medium))  // Reduced weight
                        .foregroundColor(.white)
                    
                    Text(entry.nextClass)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.nextClassTime)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#BBE7FF"))  // Changed to accent color
                }
            }
            
            Spacer()
            
            // Additional placeholder for more schedule items
            Text("Coming Up")
                .font(.system(size: 24, weight: .medium))  // Reduced weight
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

struct ScheduleRow: View {
    let className: String
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(className)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(time)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#BBE7FF"))  // Changed to accent color
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct WidgetTitle: View {
    let title: String
    let fontSize: Double
    
    var body: some View {
        return HStack {
            Text(title)
                .font(.system(size: fontSize, weight: .heavy))
                .foregroundStyle(Color.white)
            Spacer()
            Image("widgetIcon").resizable().frame(width: 30, height: 15)
        }
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

#Preview(as: .systemSmall) {
    VittyWidget()
} timeline: {
    SimpleEntry(date: .now, progress: 6, total: 7, nextClass: "Software Engineering", nextClassTime: "4:00 PM - 4:50 PM")
}
