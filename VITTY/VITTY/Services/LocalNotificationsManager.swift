//
//  NotificationsManager.swift
//  VITTY
//
//  Created by Ananya George on 1/23/22.
//

import Foundation
import UserNotifications

class LocalNotificationsManager: ObservableObject {
    
    static let shared = LocalNotificationsManager()
    
    // TODO: handle notifications
    
    //    @Published var authStatus: Bool = false
    @Published var authStatus: UNAuthorizationStatus?
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            
            guard error == nil else {
                print("There was an error when requesting permission for local notifications")
                return
            }
            
            if granted {
                print("Local notifications permission granted: \(granted)")
            } else {
                print("Local notifications permission not granted")
            }
            
            DispatchQueue.main.async {
                self.authStatus = granted ? .authorized : .denied
                
                // TODO: add push notifications request
                
            }
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authStatus = settings.authorizationStatus
            }
        }
    }
    
    func addNotifications(id: String, date: Date, day: Int, courseCode: String, courseName: String, location: String) {
        
        let notifTime = Calendar.current.date(byAdding: .minute, value: -5, to: date ?? Date()) ?? Date()
        
        let components = Calendar.current.dateComponents([.hour,.minute], from: notifTime)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        print("Creating notification for hour: \(hour), minute: \(minute), day: \(day), courseCode: \(courseCode) and name: \(courseName)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = day
        
       
        
        let content = UNMutableNotificationContent()
        content.title = StringConstants.notificationTitle
        content.body = "You have \(courseCode) \(courseName) at \(dateFormatter.string(from: date))"
        content.sound = .default
        content.categoryIdentifier = "vitty-category"
        content.userInfo = ["location":location]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else {
                print("An error occurred while creating the notification: \(error?.localizedDescription)")
                return
            }
            
            print("Notification created!")
        }
    }
    
    func removeAllNotificationRequests() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func getAllNotificationRequests() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { notifreqs in
            for notifreq in notifreqs {
                print(notifreq.identifier)
            }
        }
    }
    
    /** Handle notification when app is in background */
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:
            UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
            if response.actionIdentifier == "navigateToClass" {
                let userInfo = response.notification.request.content.userInfo
                let location = userInfo["location"] as? String
                ClassCardViewModel.classCardVM.navigateToClass(at: location ?? "location")
            }
            else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                NotificationsViewModel.shared.notificationTapped.toggle()
            }
            completionHandler()
        }
        
}

