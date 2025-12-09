//
//  GetNextClassIntent.swift
//  VittyIntents
//
//  Created for VITTY
//

import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct GetNextClassIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Next Class"
    static var description = IntentDescription("Get information about your next class")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let container = IntentHelper.getSharedContainer() else {
            return .result(
                dialog: "I couldn't access your timetable data.",
                view: NextClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TimeTable>()
        
        guard let timetable = try? context.fetch(descriptor).first else {
            return .result(
                dialog: "I couldn't find your timetable.",
                view: NextClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let today = Date()
        let calendar = Calendar.current
        let currentTime = Date()
        
        var allUpcomingClasses: [(classItem: Classes, date: Date, isToday: Bool)] = []
        
        // Get today's remaining classes
        let todayClasses = timetable.classesFor(date: today)
        
        for classItem in todayClasses {
            // Parse the start time from the time string (format: "h:mm a - h:mm a")
            let timeComponents = classItem.time.components(separatedBy: " - ")
            if timeComponents.count == 2 {
                let startTimeStr = timeComponents[0].trimmingCharacters(in: .whitespaces)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                if let startTime = dateFormatter.date(from: startTimeStr) {
                    let timeComps = calendar.dateComponents([.hour, .minute], from: startTime)
                    let todayComps = calendar.dateComponents([.year, .month, .day], from: today)
                    
                    var combinedComps = DateComponents()
                    combinedComps.year = todayComps.year
                    combinedComps.month = todayComps.month
                    combinedComps.day = todayComps.day
                    combinedComps.hour = timeComps.hour
                    combinedComps.minute = timeComps.minute
                    
                    if let classDate = calendar.date(from: combinedComps), classDate > currentTime {
                        allUpcomingClasses.append((classItem, classDate, true))
                    }
                }
            }
        }
        
        // Get tomorrow's classes
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            let tomorrowClasses = timetable.classesFor(date: tomorrow)
            
            for classItem in tomorrowClasses {
                let timeComponents = classItem.time.components(separatedBy: " - ")
                if timeComponents.count == 2 {
                    let startTimeStr = timeComponents[0].trimmingCharacters(in: .whitespaces)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    if let startTime = dateFormatter.date(from: startTimeStr) {
                        let timeComps = calendar.dateComponents([.hour, .minute], from: startTime)
                        let tomorrowComps = calendar.dateComponents([.year, .month, .day], from: tomorrow)
                        
                        var combinedComps = DateComponents()
                        combinedComps.year = tomorrowComps.year
                        combinedComps.month = tomorrowComps.month
                        combinedComps.day = tomorrowComps.day
                        combinedComps.hour = timeComps.hour
                        combinedComps.minute = timeComps.minute
                        
                        if let classDate = calendar.date(from: combinedComps) {
                            allUpcomingClasses.append((classItem, classDate, false))
                        }
                    }
                }
            }
        }
        
        // Sort by start time
        allUpcomingClasses.sort { $0.date < $1.date }
        
        guard let nextClass = allUpcomingClasses.first else {
            return .result(
                dialog: "You don't have any upcoming classes.",
                view: NextClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let dialogText: String
        if nextClass.isToday {
            let timeComponents = nextClass.classItem.time.components(separatedBy: " - ")
            let startTime = timeComponents.first ?? ""
            dialogText = "Your next class is \(nextClass.classItem.title) at \(startTime) in \(nextClass.classItem.slot ?? "unknown venue")."
        } else {
            let timeComponents = nextClass.classItem.time.components(separatedBy: " - ")
            let startTime = timeComponents.first ?? ""
            dialogText = "Your next class is \(nextClass.classItem.title) tomorrow at \(startTime) in \(nextClass.classItem.slot ?? "unknown venue")."
        }
        
        return .result(
            dialog: dialogText,
            view: NextClassSnippetView(
                className: nextClass.classItem.title,
                classTime: nextClass.classItem.time,
                classVenue: nextClass.classItem.slot
            )
        )
    }
    
}

struct NextClassSnippetView: View {
    let className: String?
    let classTime: String?
    let classVenue: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let className = className {
                Text(className)
                    .font(.headline)
                if let classTime = classTime {
                    Text(classTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let classVenue = classVenue {
                    Text(classVenue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No upcoming classes")
                    .font(.headline)
            }
        }
        .padding()
    }
}

