//
//  SmallWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

//
//  SmallWidget.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/25/25.
//

import WidgetKit
import SwiftUI

struct DueSmallWidgetView: View {
    var assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetTitle(title: "Due Today", fontSize: 12.0)
            
            ZStack {
                Color(.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(assignment.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Circle()
                            .fill(assignment.priority.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(assignment.timeRange)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(assignment.subject)
                        .font(.system(size: 10))
                        .lineLimit(1)
                        .foregroundColor(.accentBlue)
                    
                    Text(assignment.hoursLeft)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.accentBlue)
                }.padding(5)
            }
        }
    }
}




struct ScheduleSmallWidgetView: View {
    var entry: ScheduleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            WidgetTitle(title: "Schedule", fontSize: 12.0)
            Spacer().frame(height: 15)
            
            CircleProgressView(
                progress: entry.classes.count,
                total: entry.total,
                circleSize: 45,
                lineWidth: 12,
                fontSize: 12
            )
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 20)
            
            if let nextClass = entry.classes.first {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Up Next")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(nextClass.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(nextClass.time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(.accentBlue))
                }
            }
            Spacer()
        }
    }
}



#Preview("Medium Due Widget", as: .systemMedium) {
    DueWidget()
} timeline: {
    DueEntry(
        date: Date(),
        assignments: [
            Assignment(title: "Quiz 1", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA", hoursLeft: "02:00 hrs left", priority: .high,category: nil),
            Assignment(title: "Digital Assignment I", timeRange: "8 AM - 9 AM", subject: "Java Programming - ELA", hoursLeft: "12:00 hrs left", priority: .medium,category: nil),
        ]
    )
}
