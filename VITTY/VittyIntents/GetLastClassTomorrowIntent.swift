//
//  GetLastClassTomorrowIntent.swift
//  VittyIntents
//
//  Created for VITTY
//

import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct GetLastClassTomorrowIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Last Class Tomorrow"
    static var description = IntentDescription("Get your last class tomorrow")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let container = IntentHelper.getSharedContainer() else {
            return .result(
                dialog: "I couldn't access your timetable data.",
                view: ClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TimeTable>()
        
        guard let timetable = try? context.fetch(descriptor).first else {
            return .result(
                dialog: "I couldn't find your timetable.",
                view: ClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            return .result(
                dialog: "I couldn't determine tomorrow's date.",
                view: ClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let tomorrowClasses = timetable.classesFor(date: tomorrow)
        
        guard !tomorrowClasses.isEmpty else {
            return .result(
                dialog: "You don't have any classes tomorrow.",
                view: ClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        // Sort classes by time to get the last one
        let sortedClasses = tomorrowClasses.sorted { class1, class2 in
            let time1Components = class1.time.components(separatedBy: " - ")
            let time2Components = class2.time.components(separatedBy: " - ")
            
            guard time1Components.count == 2, time2Components.count == 2 else {
                return false
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let startTime1Str = time1Components[0].trimmingCharacters(in: .whitespaces)
            let startTime2Str = time2Components[0].trimmingCharacters(in: .whitespaces)
            
            guard let startTime1 = dateFormatter.date(from: startTime1Str),
                  let startTime2 = dateFormatter.date(from: startTime2Str) else {
                return false
            }
            
            return startTime1 < startTime2
        }
        
        guard let lastClass = sortedClasses.last else {
            return .result(
                dialog: "I couldn't determine your last class.",
                view: ClassSnippetView(className: nil, classTime: nil, classVenue: nil)
            )
        }
        
        let dialogText = "Your last class tomorrow is \(lastClass.title) at \(lastClass.time) in \(lastClass.slot ?? "unknown venue")."
        
        return .result(
            dialog: dialogText,
            view: ClassSnippetView(
                className: lastClass.title,
                classTime: lastClass.time,
                classVenue: lastClass.slot
            )
        )
    }
}

