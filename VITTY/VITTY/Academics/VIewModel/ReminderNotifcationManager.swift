//
//  ReminderNotifcationManager.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/18/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func scheduleReminderNotifications(title: String, date: Date,subject: String) {
       
        scheduleNotification(
            title: "\(subject): \(title)",
            body: "Your scheduled reminder is now.",
            date: date,
            identifier: "\(title)-exact"
        )

        
        let tenMinutesBefore = Calendar.current.date(byAdding: .minute, value: -10, to: date)!
        scheduleNotification(
            title: "Upcoming Reminder: \(title)",
            body: "Your reminder is in 10 minutes.",
            date: tenMinutesBefore,
            identifier: "\(title)-early"
        )
    }
}
