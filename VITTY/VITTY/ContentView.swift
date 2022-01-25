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
    // may not need this at all
    @StateObject var localNotificationsManager = LocalNotificationsManager()
    @StateObject var notifVM = NotificationsViewModel.shared
    var body: some View {
        NavigationView {
            if authState.loggedInUser != nil {
                InstructionsView()
                    .navigationTitle("")
                    .navigationBarHidden(true)
            } else {
                SplashScreen()
                    .navigationTitle("")
                    .navigationBarHidden(true)
            }
        }
        .animation(.default)
        .onAppear(perform: LocalNotificationsManager.shared.getNotificationSettings)
        .onChange(of: LocalNotificationsManager.shared.authStatus) { authorizationStat in
            
            switch authorizationStat {
            case .notDetermined:
                LocalNotificationsManager.shared.requestPermission()
                break
            default:
                break
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            LocalNotificationsManager.shared.getNotificationSettings()
        }
        .environmentObject(authState)
        .environmentObject(timeTableVM)
        .environmentObject(notifVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authState: AuthService())
    }
}
