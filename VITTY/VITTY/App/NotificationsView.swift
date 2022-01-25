//
//  NotificationsView.swift
//  VITTY
//
//  Created by Ananya George on 1/21/22.
//

import SwiftUI
import CoreMedia

struct NotificationsView: View {
    @EnvironmentObject var authVM: AuthService
    @EnvironmentObject var ttVM: TimetableViewModel
    
    @EnvironmentObject var notifVM: NotificationsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(0..<7, id: \.self) { day in
                    if !ttVM.timetable[TimetableViewModel.daysOfTheWeek[day]]!.isEmpty {
                        VStack(alignment: .leading) {
                            Text(TimetableViewModel.daysOfTheWeek[day].capitalized)
                                .font(.custom("Poppins-Semibold", size: 16))
                            ForEach($notifVM.notifSettings, id: \.self) { $notifsetting in
                                if $notifsetting.wrappedValue.day == day+1 {
                                    //                                    CustomNotificationButton(enabled: $notifsetting.enabled, dayoftheweek: day, timetable: ttVM.timetable, period: notifsetting.wrappedValue.period)
                                    
                                    Toggle(isOn: $notifsetting.enabled, label: {
                                        CustomNotificationsLabel(dayoftheweek: day, timetable: ttVM.timetable, period: $notifsetting.wrappedValue.period)})
                                }
                            }
                        }
                    }
                }
            }
        }
        
        .padding()
        .font(.custom("Poppins-Regular", size: 16))
        .foregroundColor(.white)
        .background(Image("HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        //        .navigationBarHidden(true)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        //        .navigationTitle("")
        .onDisappear {
            notifVM.updateNotificationPreferences(timetable: ttVM.timetable)
            
        }
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
