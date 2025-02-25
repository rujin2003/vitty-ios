import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
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
        VStack {
            Text("Small")
                .foregroundColor(.white)
            Text(entry.date, style: .time)
                .foregroundColor(.white)
        }
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            Text("Medium")
                .foregroundColor(.white)
            Spacer()
            Text(entry.date, style: .time)
                .foregroundColor(.white)
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Large")
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            HStack {
                Spacer()
                Text(entry.date, style: .time)
                    .foregroundColor(.white)
            }
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

#Preview(as: .systemSmall) {
    VittyWidget()
} timeline: {
    SimpleEntry(date: .now)
}

#Preview(as: .systemMedium) {
    VittyWidget()
} timeline: {
    SimpleEntry(date: .now)
}

#Preview(as: .systemLarge) {
    VittyWidget()
} timeline: {
    SimpleEntry(date: .now)
}
