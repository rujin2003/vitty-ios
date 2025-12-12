//
//  ClassesCount.swift
//  VITTY
//
//  Created by Rujin Devkota on 12/11/25.
//
import AppIntents
import SwiftData
import Foundation

struct ClassCountIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Tomorrow's Classes"
    static let description = IntentDescription("Get the number of classes tomorrow")
    static let openAppWhenRun = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // Get the shared model container
        let container = try ModelContainer(for: Timetable.self)
        let context = ModelContext(container#imageLiteral(resourceName: "d243684d-acbf-4189-82f7-ef61ace683f4.JPG"))
        
        // Fetch timetable
        let descriptor = FetchDescriptor<Timetable>()
        guard let table = try context.fetch(descriptor).first else {
            return .result(dialog: "You have not added your timetable yet.")
        }
        
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else {
            return .result(dialog: "Unable to calculate tomorrow's date.")
        }
        
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrow)
        let tomorrowLectures = table.lectures.filter { $0.day == tomorrowWeekday }
        
        let count = tomorrowLectures.count
        
        if count == 0 {
            return .result(dialog: "You have no classes tomorrow.")
        } else if count == 1 {
            return .result(dialog: "You have 1 class tomorrow.")
        } else {
            return .result(dialog: "You have \(count) classes tomorrow.")
        }
    }
}
