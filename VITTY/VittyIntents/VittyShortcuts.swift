//
//  VittyShortcuts.swift
//  VITTY
//
//  Created by Rujin Devkota on 12/11/25.
//

import AppIntents

struct VittyShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {

        [
            AppShortcut(
                intent: NextClassIntent(),
                phrases: [
                    "When is my next class",
                    "Next class in \( .applicationName )",
                    "When is my next class in \( .applicationName )"
                ],
                shortTitle: "Next Class",
                systemImageName: "calendar.badge.clock"
            ),

            AppShortcut(
                intent: ClassCountIntent(),
                phrases: [
                    "How many classes tomorrow",
                    "Classes tomorrow in \( .applicationName )"
                ],
                shortTitle: "Tomorrow Classes",
                systemImageName: "calendar"
            )
        ]
    }
}
