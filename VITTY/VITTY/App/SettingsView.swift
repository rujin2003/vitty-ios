//
//  SettingsView.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("examMode") var examModeOn: Bool = false
    var githubURL = URL(string: "https://github.com/GDGVIT/vitty-ios")
    var gdscURL = URL(string: "https://dscvit.com/")
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle(isOn: $examModeOn) {
                    VStack(alignment: .leading) {
                        Text("Exam/Holiday Mode")
                            .font(.body)
                        Text("Turns off class notifications")
                            .font(.subheadline)
                    }
                }
                NavigationLink(destination: EmptyView()) {
                    VStack(alignment: .leading) {
                        Text("Notification Settings")
                            .font(.body)
                        Text("Turn on/off individual class notifications")
                            .font(.subheadline)
                    }
                }
            }
            Section(header: Text("About")) {
                HStack {
                    Image("github_icon")
                        .resizable()
                        .scaledToFit()
                    Text("GitHub Repository")
                }
                .frame(height: 35)
                .onTapGesture {
                    if let url = githubURL {
                        UIApplication.shared.open(url)
                    }
                }
                HStack {
                    Image("gdsc_icon")
                        .resizable()
                        .scaledToFit()
                    Text("GDSC VIT")
                }
                .frame(height: 35)
                .onTapGesture {
                    if let url = gdscURL {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
