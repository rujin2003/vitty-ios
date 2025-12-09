//
//  IntentHelper.swift
//  VittyIntents
//
//  Created for VITTY
//

import Foundation
import SwiftData
import SwiftUI

// Shared helper to access timetable data
class IntentHelper {
    static func getSharedContainer() -> ModelContainer? {
        let appGroupContainerID = "group.com.gdscvit.vittyios.shared"
        
        // Use the same schema as the main app to access shared data
        // Note: These model types need to be accessible from where this code runs
        // For App Intents (iOS 16+), they run in the main app, so all models are available
        let schema = Schema([TimeTable.self, Remainder.self, CreateNoteModel.self, UploadedFile.self])
        
        let config = ModelConfiguration(
            appGroupContainerID,
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("Failed to create shared container: \(error)")
            return nil
        }
    }
    
    static func formatTime(time: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        
        if let date = formatter.date(from: time) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        
        var timeComponents = time.components(separatedBy: "T").last ?? time
        if timeComponents.contains("+") {
            timeComponents = timeComponents.components(separatedBy: "+").first ?? timeComponents
        }
        if timeComponents.contains("Z") {
            timeComponents = timeComponents.components(separatedBy: "Z").first ?? timeComponents
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        
        if let date = dateFormatter.date(from: timeComponents) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        
        let timePattern = "\\d{2}:\\d{2}"
        if let range = timeComponents.range(of: timePattern, options: .regularExpression) {
            let timeOnly = String(timeComponents[range])
            dateFormatter.dateFormat = "HH:mm"
            
            if let date = dateFormatter.date(from: timeOnly) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "h:mm a"
                displayFormatter.locale = Locale(identifier: "en_US_POSIX")
                return displayFormatter.string(from: date)
            }
        }
        
        return "Invalid Time"
    }
    
    static func parseTimeToDate(_ timeString: String, for date: Date) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        
        if let originalDate = formatter.date(from: timeString) {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: originalDate)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            combinedComponents.second = timeComponents.second
            
            return calendar.date(from: combinedComponents)
        }
        
        // Fallback parsing
        var timeComponents = timeString.components(separatedBy: "T").last ?? timeString
        if timeComponents.contains("+") {
            timeComponents = timeComponents.components(separatedBy: "+").first ?? timeComponents
        }
        if timeComponents.contains("Z") {
            timeComponents = timeComponents.components(separatedBy: "Z").first ?? timeComponents
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
        
        if let time = dateFormatter.date(from: timeComponents) {
            let calendar = Calendar.current
            let timeComps = calendar.dateComponents([.hour, .minute, .second], from: time)
            let dateComps = calendar.dateComponents([.year, .month, .day], from: date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComps.year
            combinedComponents.month = dateComps.month
            combinedComponents.day = dateComps.day
            combinedComponents.hour = timeComps.hour
            combinedComponents.minute = timeComps.minute
            combinedComponents.second = timeComps.second
            
            return calendar.date(from: combinedComponents)
        }
        
        return nil
    }
}

