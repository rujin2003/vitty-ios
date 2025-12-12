//
//  NextclassIntent.swift
//  VITTY
//
//  Created by Rujin Devkota on 12/11/25.
//

import AppIntents
import SwiftData
import Foundation

struct NextClassIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Next Class"
    static let description = IntentDescription("Get your next upcoming class")
    static let openAppWhenRun = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // Get the shared model container
        let container = try ModelContainer(for: Timetable.self)
        let context = ModelContext(container)
        
        // Fetch timetable
        let descriptor = FetchDescriptor<Timetable>()
        guard let table = try context.fetch(descriptor).first else {
            return .result(dialog: "You have not added your timetable yet.")
        }
        
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        
        // Get today's lectures
        let todayLectures = table.lectures.filter { lecture in
            lecture.day == weekday
        }
        
        // Sort by start time
        let sorted = todayLectures.sorted { lecture1, lecture2 in
            let time1 = parseTime(lecture1.startTime)
            let time2 = parseTime(lecture2.startTime)
            return time1 < time2
        }
        
        // Find next class today
        for lecture in sorted {
            let lectureTime = parseTime(lecture.startTime)
            if lectureTime > now {
                let timeStr = formatTime(lecture.startTime)
                return .result(
                    dialog: "Your next class is \(lecture.name) at \(timeStr) in \(lecture.venue)."
                )
            }
        }
        
        // No more classes today - check tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return .result(dialog: "You have no upcoming classes.")
        }
        
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrow)
        let tomorrowLectures = table.lectures.filter { $0.day == tomorrowWeekday }
            .sorted { parseTime($0.startTime) < parseTime($1.startTime) }
        
        if let first = tomorrowLectures.first {
            let timeStr = formatTime(first.startTime)
            return .result(
                dialog: "You have no more classes today. Your next class is \(first.name) tomorrow at \(timeStr)."
            )
        }
        
        return .result(dialog: "You have no upcoming classes.")
    }
    
    // Helper to parse "HH:mm" to today's date
    private func parseTime(_ timeString: String) -> Date {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return Date.distantFuture
        }
        
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return calendar.date(from: dateComponents) ?? Date.distantFuture
    }
    
    // Helper to format time for display
    private func formatTime(_ timeString: String) -> String {
        let date = parseTime(timeString)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
