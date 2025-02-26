//
//  LargeWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//
import SwiftUI
import WidgetKit


struct LargeDueWidgetView: View {
    var assignments: [Assignment]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WidgetTitle(title: "Reminders", fontSize: 18.0)

            if !assignments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Due Today")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 6) {
                        ForEach(assignments.prefix(3), id: \.title) { assignment in
                            AssignmentRow(assignment: assignment,titleFont: 15,subjectFont: 13,hoursLeft: 13)
                            
                           
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Upcoming")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 6) {
                        ForEach(assignments.dropFirst(3).prefix(3), id: \.title) { assignment in
                            AssignmentRow(assignment: assignment,titleFont: 14,subjectFont: 12,hoursLeft: 12)
                        }
                    }
                }
            } else {
                Text("No assignments due.")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
        .padding(12)
        
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Large Due Widget", as: .systemLarge) {
    DueWidget()
} timeline: {
    DueEntry(
        date: Date(),
        assignments: [
            // Due Today
            Assignment(title: "Quiz 1",
                       timeRange: "8 AM - 9 AM",
                       subject: "Java Programming - ELA",
                       hoursLeft: "02:00 hrs left",
                       priority: .high,
                       category: .dueToday),
            Assignment(title: "Digital Assignment I",
                       timeRange: "8 AM - 9 AM",
                       subject: "Java Programming - ELA",
                       hoursLeft: "12:00 hrs left",
                       priority: .medium,
                       category: .dueToday),
            
            // Upcoming
            Assignment(title: "Midterm Project",
                       timeRange: "8 AM - 9 AM",
                       subject: "Software Engineering - ETH",
                       hoursLeft: "2 days left",
                       priority: .low,
                       category: .upcoming),
            Assignment(title: "Lab Report",
                       timeRange: "8 AM - 9 AM",
                       subject: "Software Engineering - ETH",
                       hoursLeft: "3 days left",
                       priority: .low,
                       category: .upcoming)
        ]
    )
}
