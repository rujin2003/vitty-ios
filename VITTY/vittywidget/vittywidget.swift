//
//  vittywidget.swift
//  vittywidget
//
//  Created by Chandram Dutta on 04/03/24.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
	}

	func snapshot(
		for configuration: ConfigurationAppIntent,
		in context: Context
	) async -> SimpleEntry {
		SimpleEntry(date: Date(), configuration: configuration)
	}

	func timeline(
		for configuration: ConfigurationAppIntent,
		in context: Context
	) async -> Timeline<SimpleEntry> {
		var entries: [SimpleEntry] = []

		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0..<5 {
			let entryDate = Calendar.current.date(
				byAdding: .hour,
				value: hourOffset,
				to: currentDate
			)!
			let entry = SimpleEntry(date: entryDate, configuration: configuration)
			entries.append(entry)
		}

		return Timeline(entries: entries, policy: .atEnd)
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	let configuration: ConfigurationAppIntent
}

struct vittywidgetEntryView: View {
	var entry: Provider.Entry

	var body: some View {
		VStack {
			Text("Time:")
			Text(entry.date, style: .time)

			Text("Favorite Emoji:")
			Text(entry.configuration.favoriteEmoji)
		}
	}
}

struct vittywidget: Widget {
	let kind: String = "vittywidget"

	var body: some WidgetConfiguration {
		AppIntentConfiguration(
			kind: kind,
			intent: ConfigurationAppIntent.self,
			provider: Provider()
		) { entry in
			vittywidgetEntryView(entry: entry)
				.containerBackground(.fill.tertiary, for: .widget)
		}
	}
}

extension ConfigurationAppIntent {
	fileprivate static var smiley: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.favoriteEmoji = "😀"
		return intent
	}

	fileprivate static var starEyes: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.favoriteEmoji = "🤩"
		return intent
	}
}

#Preview(as: .systemSmall) {
	vittywidget()
} timeline: {
	SimpleEntry(date: .now, configuration: .smiley)
	SimpleEntry(date: .now, configuration: .starEyes)
}
