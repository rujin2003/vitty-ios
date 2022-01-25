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
    
    func addNotifications(id: String, hour: Int, minute: Int, day: Int, courseCode: String, courseName: String) {
        
        print("Creating notification for hour: \(hour), minute: \(minute), day: \(day), courseCode: \(courseCode) and name: \(courseName)")
        let content = UNMutableNotificationContent()
        content.title = StringConstants.notificationTitle
        content.body = "\(courseCode) \(courseName)"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = day
        
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
}

