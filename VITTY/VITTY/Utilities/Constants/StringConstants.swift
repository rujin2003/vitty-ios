//
//  StringConstants.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import Foundation

struct StringConstants {
    // MARK: SPLASH SCREEN CONSTANTS
    static let splashScreenHeader = [
        "Never Miss a Class!",
        "Get a sneak peek",
        "Upload once, view everywhere",
    ]
    static let splashScreenDescription = [
        "Notifications to remind you about your classes",
        "View your upcoming classes and timetable via the widget",
        "Instant sync across all of your devices via the app and extension",
    ]
    // MARK: HOME PAGE CONSTANTS
    static let daysOfTheWeek = [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
    ]
    // MARK: INSTRUCTIONS PAGE
    // dummy arrays
    static let instructionsHeaders = ["Account Details", "Setup Instructions"]
    static let accData = ["Name: ","Signed in with: ","Email: "]
    static let sampleData = ["Name: Ryan Ross","Email: blinkexists182@aol.com"]
    static let setupInstructions = [
        "1. Download the Chrome Extension from: https://dscv.it/vitty-extension", // make the link tappable
        "2. Log in with the same Google/Apple Account as shown above",
        "3. Upload a screenshot of your timetable",
        "4. Review it",
        "5. When done, click on Upload."
    ]
    static let setupFinalText = "BRAVO! That's it. You did it!"
    
    // MARK: CLASS DATA
    static let sampleClassDate = Classes(courseType: "Theory", courseCode: "MAT3004", courseName: "Applied Linear Algebra", location: "SJT112", slot: "A1", startTime: Date(), endTime: Date(timeIntervalSinceNow: 3600))
    
    // MARK: RANDOM STRINGS
    static let noClassQuotesOnline = [
        "Up for some Valorant Grind?",
        "Don't you have a quiz coming up?",
        "Finish your DAs!",
        "Read a book!",
        "Catch up on some sleep!"
    ]
    
    static let noClassQuotesOffline = [
        "Don't you have a quiz coming up?",
        "Finish your DAs!",
        "Chill and relax in hostel",
        "Let's chill at Foodys!",
        "Ready to run to Tarama?",
        "Do grocery shopping at Allmart"
    ]
    
    // MARK: NOTIFICATIONS
    static let notificationTitle = "Join your next class!"
}
