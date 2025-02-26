import SwiftUI
import WidgetKit

struct ScheduleMediumWidgetView: View {
    var entry: ScheduleEntry

    var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 2)
            VStack(alignment: .leading, spacing: 10) {
                WidgetTitle(title: "Today's Schedule", fontSize: 15)
                Spacer().frame(height: 1)
                
                HStack(alignment: .top, spacing: 10) {
                    if entry.classes.isEmpty {
                        VStack {
                            Text("No classes today! Time to\n relax and recharge!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Spacer().frame(height: 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else if entry.classes.count == entry.total {
                      
                        CircleProgressView(
                            progress: entry.classes.count,
                            total: entry.total,
                            circleSize: 50,
                            lineWidth: 10,
                            fontSize: 14
                        )
                        .frame(width: 60, height: 60)
                        
                        Image("allclassesline").resizable().frame(width: 10, height: 85)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer().frame(height: 10)
                            Text("You're all set for the day.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Time to relax.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                    } else {
                     
                        CircleProgressView(
                            progress: entry.classes.count,
                            total: entry.total,
                            circleSize: 50,
                            lineWidth: 10,
                            fontSize: 14
                        )
                        .frame(width: 60, height: 60)
                        
                        Image("twoclassline").resizable().frame(width: 10, height: 85)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(entry.classes.prefix(2), id: \.title) { classItem in
                                ScheduleItemView(
                                    title: classItem.title,
                                    time: "\(classItem.time) | \(classItem.slot ?? "")"
                                )
                            }
                            
                            if entry.classes.count > 2 {
                                Text("+\(entry.classes.count - 2) More")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}


struct DueMediumWidgetView: View {
    var assignments: [Assignment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetTitle(title: "Due Today", fontSize: 16.0)
            
            VStack(spacing: 6) {
                ForEach(assignments.indices, id: \.self) { index in
                    if index < 3 {
                        AssignmentRow(assignment: assignments[index],titleFont: 14,subjectFont: 10,hoursLeft: 10)
                    }
                }
            }
        }
        .padding(12)
    }
}


// MARK: - Schedule Item View
struct ScheduleItemView: View {
    var title: String
    var time: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            Text(time)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#BBE7FF"))
        }
    }
}

#Preview("Medium Schedule Widget", as: .systemMedium) {
    VittyWidget()
} timeline: {
    ScheduleEntry(
        date: Date(),
        total: 5,
        classes: [
            Class(title: "Software Engineering", time: "4:00 PM - 4:50 PM", slot: "A1 + TA1"),
                Class(title: "Java Programming", time: "5:00 PM - 5:50 PM", slot: "A1 + TA1"),
            Class(title: "Machine Learning", time: "6:00 PM - 6:50 PM", slot: "B2 + TB2")
        ]
    )
}
