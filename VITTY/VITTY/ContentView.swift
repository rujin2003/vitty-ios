//
//  ContentView.swift
//  VITTY
//
//  Created by Ananya George on 11/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var timeTableExists = false
    @StateObject var authState: AuthService = AuthService()
    var body: some View {
        NavigationView {
            if authState.loggedInUser != nil {
                if timeTableExists {
                    HomePage()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                } else {
                    InstructionsView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
            } else {
            SplashScreen()
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
        .animation(.easeInOut)
        .environmentObject(authState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authState: AuthService())
    }
}
