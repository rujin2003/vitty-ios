//
//  HomeView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct HomeView: View {
	
	@State private var selectedPage = 1
	
	var body: some View {
		ZStack (alignment: .bottom) {
			switch (selectedPage) {
//			case 0:
//				NavigationStack {
//					ZStack {
//						BackgroundView()
//					}
//					.navigationTitle("Courses")
//				}
			case 1:
				TimeTableView(friend: nil)
					.tabItem {
						Label("Schedule", systemImage: "calendar.day.timeline.left")
					}
			case 2:
				ConnectPage()
					.tabItem {
						Label("Connect", systemImage: "person.2")
					}
			default:
				Text("Error Lol")
			}
			BottomBarView(presentTab: $selectedPage)
				.padding(.bottom, 24)
		}
	}
}

#Preview {
	HomeView()
}
