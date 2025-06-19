import Foundation
import SwiftUI
import UserNotifications


class SettingsViewModel : ObservableObject{
    var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
               
                if let timetable = self.timetable {
                    self.scheduleAllNotifications(from: timetable)
                }
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                showNotificationDisabledAlert = true
            }
        }
    }

    var timetable: TimeTable?
    var showNotificationDisabledAlert = false

    init(timetable: TimeTable? = nil) {
        self.timetable = timetable
        // Load the stored value
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        checkNotificationAuthorization()
    }

    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func requestNotificationPermission() {
        // Since you handle permission elsewhere, this method can be simplified or removed
        // Just schedule notifications if permission is already granted
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    if let timetable = self.timetable {
                        self.scheduleAllNotifications(from: timetable)
                    }
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func scheduleAllNotifications(from timetable: TimeTable) {
        let weekdays: [(Int, [Lecture])] = [
            (2, timetable.monday),
            (3, timetable.tuesday),
            (4, timetable.wednesday),
            (5, timetable.thursday),
            (6, timetable.friday),
            (7, timetable.saturday),
            (1, timetable.sunday)
        ]

        for (weekday, lectures) in weekdays {
            for lecture in lectures {
                guard let startDate = parseLectureTime(lecture.startTime, weekday: weekday) else { continue }

                scheduleNotification(for: lecture.name, at: startDate, title: "Class Starting", minutesBefore: 0)
                scheduleNotification(for: lecture.name, at: startDate, title: "Upcoming Class", minutesBefore: 10)
            }
        }
    }

    private func scheduleNotification(for lectureName: String, at date: Date, title: String, minutesBefore: Int) {
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date) ?? date

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(lectureName) is starting soon."
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "\(lectureName)-\(title)-\(triggerDate)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func parseLectureTime(_ timeString: String, weekday: Int) -> Date? {
        var cleaned = timeString.components(separatedBy: "T").last ?? ""
        cleaned = cleaned.components(separatedBy: "Z").first ?? ""

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        guard let time = formatter.date(from: cleaned) else { return nil }

        var components = Calendar.current.dateComponents([.year, .month, .weekOfYear], from: Date())
        components.weekday = weekday
        components.hour = Calendar.current.component(.hour, from: time)
        components.minute = Calendar.current.component(.minute, from: time)

        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
    }
}
