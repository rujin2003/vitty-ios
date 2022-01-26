//
//  HomePage.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomePage: View {
    @State var tabSelected: Int = (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1
    @State var goToSettings: Bool = false
    @State var showLogout: Bool = false
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    @EnvironmentObject var authVM: AuthService
    @EnvironmentObject var notifVM: NotificationsViewModel
    @AppStorage("examMode") var examModeOn: Bool = false
    @AppStorage(AuthService.notifsSetupKey) var notifsSetup = false
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment:.leading) {
                    HomePageHeader(goToSettings: $goToSettings, showLogout: $showLogout)
                        .padding()
                    HomeTabBarView(tabSelected: $tabSelected)
                }
                if let selectedTT = timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]] {
                    if !selectedTT.isEmpty {
                        TimeTableScrollView(selectedTT: selectedTT, tabSelected: $tabSelected).environmentObject(timetableViewModel)
                    }
                    else {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("No class today!")
                                .font(Font.custom("Poppins-Bold", size: 24))
                            Text(StringConstants.noClassQuotesOnline.randomElement() ?? "Have fun today!")
                                .font(Font.custom("Poppins-Regular",size:20))
                        }
                        .foregroundColor(Color.white)
                        Spacer()
                    }
                }
                NavigationLink(destination: SettingsView().environmentObject(timetableViewModel).environmentObject(authVM).environmentObject(notifVM), isActive: $goToSettings) {
                    EmptyView()
                }
                if examModeOn {
                    ExamHolidayMode()
                }
            }
            .onAppear {
                tabSelected = (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1
            }
            if showLogout {
                LogoutPopup(showLogout: $showLogout).environmentObject(authVM)
            }
        }
        .padding(.top)
        .background(Image(timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]]?.isEmpty ?? false ? "HomeNoClassesBG" : "HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        .onAppear {
            timetableViewModel.getData {
                if !notifsSetup {
                    notifVM.setupNotificationPreferences(timetable: timetableViewModel.timetable)
                    print("Notifications set up")
                }
                
            }
            //            LocalNotificationsManager.shared.getAllNotificationRequests()
            notifVM.updateNotifs(timetable: timetableViewModel.timetable)
            timetableViewModel.updateClassCompleted()
            notifVM.getNotifPrefs()
            
            print(goToSettings)
        }
        .animation(.default)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
