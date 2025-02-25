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
    var entry: DueEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          
            WidgetTitle(title: "Due Today", fontSize: 12.0)
            
            ZStack {
                Color(hex: "#071F33")
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(entry.timeRange)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(entry.subject)
                        .font(.system(size: 10))
                        .lineLimit(1)
                        .foregroundColor(Color(hex: "#BBE7FF"))
                    
                    Text(entry.hoursLeft)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#BBE7FF"))
                }.padding(5)
                
            }
        }
       
    }
}


struct ScheduleSmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            WidgetTitle(title: "Schedule", fontSize: 12.0)
            
            Spacer().frame(height: 15)
            
          
            CircleProgressView(
                progress: entry.progress,
                total: entry.total,
                circleSize: 45,
                lineWidth: 12,
                fontSize: 12
            )
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 20)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Up Next")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                
                Text(entry.nextClass)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.nextClassTime)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#BBE7FF"))
            }
            
            Spacer()
        }
    }
}



#Preview("Due Small", as: .systemSmall) {
    DueWidget()
} timeline: {
    DueEntry(date: .now, title: "Quiz 1", timeRange: "8 AM - 9 AM", subject: "Java Programming", hoursLeft: "02:00 hrs left")
}
