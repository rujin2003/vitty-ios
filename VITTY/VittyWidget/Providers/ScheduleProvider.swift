//
//  ScheduleProvider.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/12/25.
//
//

import SwiftUI
import SwiftData
import WidgetKit

struct Provider: TimelineProvider {
    
    private func getSharedContainer() -> ModelContainer? {
        let appGroupContainerID = "group.com.gdscvit.vittyioswidget"
        let config = ModelConfiguration(appGroupContainerID)
        
        return try? ModelContainer(for: TimeTable.self, configurations: config)
    }
    
    // MARK: - Time Parsing and Validation
    
    private func parseTimeString(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let cleanedTime = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let time = formatter.date(from: cleanedTime) {
            let calendar = Calendar.current
            let now = Date()
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                               minute: timeComponents.minute ?? 0,
                               second: 0,
                               of: now)
        }
        return nil
    }
    
    private func parseClassTime(_ timeRange: String) -> (start: Date?, end: Date?) {
        let components = timeRange.components(separatedBy: " - ")
        guard components.count == 2 else { return (nil, nil) }
        
        let startTime = parseTimeString(components[0])
        let endTime = parseTimeString(components[1])
        
        return (startTime, endTime)
    }
    
    // MARK: - Class Status Determination
    
    private enum ClassStatus {
        case upcoming
        case current
        case completed
    }
    
    private func getClassStatus(_ classItem: Classes, at currentTime: Date = Date()) -> ClassStatus {
        let (startTime, endTime) = parseClassTime(classItem.time)
        
        guard let start = startTime, let end = endTime else {
            return .upcoming
        }
        
        if currentTime < start {
            return .upcoming
        } else if currentTime >= start && currentTime <= end {
            return .current
        } else {
            return .completed
        }
    }
    
    // MARK: - Data Fetching Methods
    
    private func fetchAllTodaysClasses() -> [Classes] {
        guard let container = getSharedContainer() else { return [] }
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<TimeTable>()
        guard let timetable = try? context.fetch(descriptor).first else {
            return []
        }
        
        return timetable.classesFor(date: Date())
    }
    
    private func fetchUpcomingClasses() -> [Classes] {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.filter { classItem in
            getClassStatus(classItem, at: currentTime) == .upcoming
        }
    }
    
    private func fetchCurrentClass() -> Classes? {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.first { classItem in
            getClassStatus(classItem, at: currentTime) == .current
        }
    }
    
    private func calculateCompletedClassesCount() -> Int {
        let allClasses = fetchAllTodaysClasses()
        let currentTime = Date()
        
        return allClasses.filter { classItem in
            getClassStatus(classItem, at: currentTime) == .completed
        }.count
    }
    
    // MARK: - Widget Content Preparation
    
    private func prepareWidgetContent() -> (classes: [Classes], total: Int, completed: Int) {
        let allClasses = fetchAllTodaysClasses()
        let upcomingClasses = fetchUpcomingClasses()
        let currentClass = fetchCurrentClass()
        let completedCount = calculateCompletedClassesCount()
        
        var displayClasses: [Classes] = []
        
       
        if let current = currentClass {
            displayClasses.append(current)
        }
        
       
        displayClasses.append(contentsOf: upcomingClasses)
        
        return (
            classes: displayClasses,
            total: allClasses.count,
            completed: completedCount
        )
    }
    
    // MARK: - Timeline Provider Methods
    
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            total: 7,
            classes: [
                Classes(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1")
            ],
            completed: 2
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let content = prepareWidgetContent()
        
        completion(ScheduleEntry(
            date: Date(),
            total: content.total,
            classes: content.classes,
            completed: content.completed
        ))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        let content = prepareWidgetContent()
        let currentTime = Date()
        
        let entry = ScheduleEntry(
            date: currentTime,
            total: content.total,
            classes: content.classes,
            completed: content.completed
        )
        
       
        let nextRefreshTime = calculateNextRefreshTime(currentTime: currentTime, classes: content.classes)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextRefreshTime))
        completion(timeline)
    }
    
    // MARK: - Smart Refresh Timing
    
    private func calculateNextRefreshTime(currentTime: Date, classes: [Classes]) -> Date {
        let calendar = Calendar.current
        
       
        var nextSignificantTime: Date?
        
        for classItem in classes {
            let (startTime, endTime) = parseClassTime(classItem.time)
            
            
            if let start = startTime, start > currentTime {
                if nextSignificantTime == nil || start < nextSignificantTime! {
                    nextSignificantTime = start
                }
            }
            
           
            if let end = endTime, end > currentTime {
                if nextSignificantTime == nil || end < nextSignificantTime! {
                    nextSignificantTime = end
                }
            }
        }
        
       
        if let significantTime = nextSignificantTime {
            return significantTime
        }
        
      
        return calendar.date(byAdding: .minute, value: 15, to: currentTime) ?? currentTime
    }
}
