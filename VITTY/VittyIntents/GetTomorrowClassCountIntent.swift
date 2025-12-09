//
//  GetTomorrowClassCountIntent.swift
//  VittyIntents
//
//  Created for VITTY
//

import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct GetTomorrowClassCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Tomorrow Class Count"
    static var description = IntentDescription("Get the count of classes you have tomorrow")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let container = IntentHelper.getSharedContainer() else {
            return .result(
                dialog: "I couldn't access your timetable data.",
                view: ClassCountSnippetView(count: nil)
            )
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TimeTable>()
        
        guard let timetable = try? context.fetch(descriptor).first else {
            return .result(
                dialog: "I couldn't find your timetable.",
                view: ClassCountSnippetView(count: nil)
            )
        }
        
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            return .result(
                dialog: "I couldn't determine tomorrow's date.",
                view: ClassCountSnippetView(count: nil)
            )
        }
        
        let tomorrowClasses = timetable.classesFor(date: tomorrow)
        let count = tomorrowClasses.count
        
        let dialogText: String
        if count == 0 {
            dialogText = "You don't have any classes tomorrow."
        } else if count == 1 {
            dialogText = "You have 1 class tomorrow."
        } else {
            dialogText = "You have \(count) classes tomorrow."
        }
        
        return .result(
            dialog: dialogText,
            view: ClassCountSnippetView(count: count)
        )
    }
}

struct ClassCountSnippetView: View {
    let count: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let count = count {
                Text("Tomorrow's Classes")
                    .font(.headline)
                Text("\(count) \(count == 1 ? "class" : "classes")")
                    .font(.title2)
                    .foregroundColor(.secondary)
            } else {
                Text("Unable to get class count")
                    .font(.headline)
            }
        }
        .padding()
    }
}

