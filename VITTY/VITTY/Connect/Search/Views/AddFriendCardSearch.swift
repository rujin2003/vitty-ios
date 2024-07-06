//
//  AddFriendCard.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import OSLog
import SwiftUI

struct AddFriendCardSearch: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: AddFriendCard.self
		)
	)

	@Binding var friend: Friend
	let search: String?
	var body: some View {
		HStack {
			UserImage(url: friend.picture, height: 48, width: 48)
			VStack(alignment: .leading) {
				Text(friend.name)
					.font(Font.custom("Poppins-SemiBold", size: 15))
					.foregroundColor(Color.white)
				Text(friend.username)
					.font(Font.custom("Poppins-Regular", size: 14))
					.foregroundColor(Color("Accent"))
			}
			Spacer()
			if friend.friendStatus != "sent" && friend.friendStatus != "friends" {
				Button("Send Request") {

					Task {
						let url = URL(
							string:
								"\(APIConstants.base_url)/api/v2/requests/\(friend.username)/send"
						)!
						print("\(APIConstants.base_url)/api/v2/requests/\(friend.username)/send")
						var request = URLRequest(url: url)

						request.httpMethod = "POST"
						request.addValue(
							"Bearer \(authViewModel.loggedInBackendUser?.token ?? "")",
							forHTTPHeaderField: "Authorization"
						)
						do {
							let (_, _) = try await URLSession.shared.data(for: request)
							suggestedFriendsViewModel.fetchData(
								from: "\(APIConstants.base_url)/api/v2/users/suggested/",
								token: authViewModel.loggedInBackendUser?.token ?? "",
								loading: false
							)
							if search != nil {
								friend.friendStatus = "sent"
							}
						}
						catch {
							return
						}
					}

				}
				.buttonStyle(.bordered)
				.font(.caption)
			}
			else {
				Image(systemName: "person.fill.checkmark")
			}
		}
		.padding(.bottom)
	}
}
