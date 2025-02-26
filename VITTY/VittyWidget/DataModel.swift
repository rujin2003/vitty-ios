//
//  DataModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

import SwiftUI
import WidgetKit

struct ScheduleEntry: TimelineEntry {
    var date: Date
    var total: Int
    var classes: [Class]
}

struct Class {
    let title: String
    let time: String
    var slot: String?
}


struct DueEntry: TimelineEntry {
    let date: Date
    let assignments: [Assignment]
    
    
    func dueTodayAssignments() -> [Assignment] {
        return assignments.filter { $0.category == .dueToday }
    }
    
    func upcomingAssignments() -> [Assignment] {
        return assignments.filter { $0.category == .upcoming }
    }
}

struct Assignment {
    let title: String
    let timeRange: String
    let subject: String
    let hoursLeft: String
    let priority: AssignmentPriority
    let category: AssignmentCategory?
}

enum AssignmentCategory: String {
    case dueToday = "Due Today"
    case upcoming = "Upcoming"
}


enum AssignmentPriority {
    case high, medium, low
    
    var color: Color {
        switch self {
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}
