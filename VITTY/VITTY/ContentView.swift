//
//  ContentView.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var authState: AuthService = AuthService()
    @StateObject var timeTableVM: TimetableViewModel = TimetableViewModel()
    var body: some View {
        NavigationView {
            if authState.loggedInUser != nil {
//                if  UserDefaults.standard.bool(forKey: "instructionsComplete"){
//                    HomePage()
//                        .navigationTitle("")
//                        .navigationBarHidden(true)
//                } else {
                    InstructionsView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
//                }
            } else {
            SplashScreen()
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
        .animation(.default)
        .environmentObject(authState)
        .environmentObject(timeTableVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authState: AuthService())
    }
}
