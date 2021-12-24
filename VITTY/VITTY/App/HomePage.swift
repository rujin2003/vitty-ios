//
//  HomePage.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomePage: View {
    @State var noClass: Bool =  false
    @State var tabSelected: Int = 0
    @State var goToSettings: Bool = false
    @State var showLogout: Bool = false
    @AppStorage("examMode") var examModeOn: Bool = false
    var body: some View {
//        NavigationView {
            ZStack {
                VStack {
                    VStack(alignment:.leading) {
                        HomePageHeader(goToSettings: $goToSettings, showLogout: $showLogout)
                            .padding()
                        HomeTabBarView(tabSelected: $tabSelected)
                    }
                    if !noClass {
                        ScrollView {
                            ForEach(0..<5) { i in
                                ClassCards()
                                    .padding(.vertical,5)
                            }
                        }
                    } else {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("No class")
                                .font(Font.custom("Poppins-Bold", size: 24))
                            Text("Small text")
                                .font(Font.custom("Poppins-Regular",size:20))
                        }
                        .foregroundColor(Color.white)
                        Spacer()
                    }
                    NavigationLink(destination: SettingsView(), isActive: $goToSettings) {
                        EmptyView()
                    }
                    if examModeOn {
                        ExamHolidayMode()
                    }
                }
                if showLogout {
                    LogoutPopup(showLogout: $showLogout)
                }
            }
            .padding(.top)
            .background(Image(noClass ? "HomeNoClassesBG" : "HomeBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
//        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
