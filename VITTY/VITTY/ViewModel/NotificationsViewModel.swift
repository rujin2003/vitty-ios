//
//  NotificationsViewModel.swift
//  VITTY
//
//  Created by Ananya George on 1/22/22.
//

import Foundation
import UserNotifications

class NotificationsViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsViewModel()
    static let notifKey = "notificationsKey"
    
    @Published var notifSettings: [NotificationsSettingsModel] = []
    
    func setupNotificationPreferences(timetable: [String:[Classes]]) {
        // this will be called in the completion handler after the timetable is fully populated
        // iterate through each day
        var temporaryArray: [NotificationsSettingsModel] = []
        for day in 0..<7 {
            let currentDay = TimetableViewModel.daysOfTheWeek[day]
            var temporaryArr: [NotificationsSettingsModel] = []
            if let currentDayClasses = timetable[currentDay] {
                if !currentDayClasses.isEmpty {
                    for aclass in 0..<currentDayClasses.count {
                        let notifsetting = NotificationsSettingsModel(id: UUID().uuidString, enabled: true, day: (day+1), period: aclass)
                        temporaryArr.append(notifsetting)
                    }
                }
                temporaryArray.append(contentsOf: temporaryArr)
            }
        }
        self.notifSettings = temporaryArray
        saveNotifSettingsToUserDefaults()
        self.updateNotificationPreferences(timetable: timetable)
        LocalNotificationsManager.shared.getAllNotificationRequests()
    }
    
    
    func updateNotificationPreferences(timetable: [String:[Classes]]) {
        // remove all notification requests
        LocalNotificationsManager.shared.removeAllNotificationRequests()
        // save notif preferences to userdefaults
        self.saveNotifSettingsToUserDefaults()
        // iterate through notification preferences
        for period in self.notifSettings {
            
            if period.enabled {
                let currClass = timetable[TimetableViewModel.daysOfTheWeek[period.day - 1]]?[period.period]
                let components = Calendar.current.dateComponents([.hour, .minute], from: currClass?.startTime ?? Date())
                let hour = components.hour ?? 0
                let minute = components.minute ?? 0
                LocalNotificationsManager.shared.addNotifications(id: period.id ?? "id", hour: hour, minute: minute, day: period.day, courseCode: currClass?.courseCode ?? "Course Code", courseName: currClass?.courseName ?? "Course Name")
            }
            
        }
        LocalNotificationsManager.shared.getAllNotificationRequests()
        
    }
    
    func saveNotifSettingsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.notifSettings) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: NotificationsViewModel.notifKey)
        }
    }
    
    func getNotifPrefs() {
        guard let notifData = UserDefaults.standard.data(forKey: NotificationsViewModel.notifKey) else {
            print("No notification settings stored")
            return
        }
        guard let notifArray = try? JSONDecoder().decode([NotificationsSettingsModel].self, from: notifData) else {
            print("Couldn't decode data")
            return
        }
        self.notifSettings = notifArray
    }
}
