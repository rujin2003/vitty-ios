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
    @AppStorage("examMode") var examModeOn: Bool = false
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
                        ScrollView {
                            ScrollViewReader { scrollView in
                                ForEach(0..<selectedTT.count, id:\.self) { ind in
                                    ClassCards(classInfo: selectedTT[ind], currentClass: timetableViewModel.classesCompleted == ind && tabSelected == (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1)
                                        .padding(.vertical,5)
                                        .id(ind)
                                }
                                .onAppear {
                                    timetableViewModel.updateClassCompleted()
                                    scrollView.scrollTo(timetableViewModel.classesCompleted)
                            }
                            }
                        }
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
                NavigationLink(destination: SettingsView(), isActive: $goToSettings) {
                    EmptyView()
                }
                if examModeOn {
                    ExamHolidayMode()
                }
            }
            if showLogout {
                LogoutPopup(showLogout: $showLogout).environmentObject(authVM)
            }
        }
        .padding(.top)
        .background(Image(timetableViewModel.timetable[TimetableViewModel.daysOfTheWeek[tabSelected]]?.isEmpty ?? false ? "HomeNoClassesBG" : "HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        .onAppear {
            timetableViewModel.getData()
        }
        .animation(.default)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
