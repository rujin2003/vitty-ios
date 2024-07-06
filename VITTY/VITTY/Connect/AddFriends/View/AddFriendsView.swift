//
//  AddFriendsView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct AddFriendsView: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel

	@State private var isSearchViewPresented = false

	var body: some View {
		NavigationStack {
			ZStack {
				BackgroundView()
				VStack(alignment: .leading) {
					if !suggestedFriendsViewModel.suggestedFriends.isEmpty
						|| !friendRequestViewModel.requests.isEmpty
					{
						VStack(alignment: .leading) {
							if !suggestedFriendsViewModel.suggestedFriends.isEmpty {
								Text("Suggested Friends")
									.font(Font.custom("Poppins-Regular", size: 14))
									.foregroundColor(Color("Accent"))
									.padding(.top)
									.padding(.horizontal)
								SuggestedFriendsView()
									.padding(.horizontal)

							}
							Spacer()
						}
					}
					else {
						Spacer()
						Text("Request and Suggestions")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-SemiBold", size: 18))
							.foregroundColor(Color.white)
						Text("Your friend requests and suggested friends will be shown here")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-Regular", size: 12))
							.foregroundColor(Color.white)
						Spacer()
					}
				}
			}
			.toolbar {
				Button(action: {
					isSearchViewPresented = true
				}) {
					Image(systemName: "magnifyingglass")
						.foregroundColor(.white)
				}
				.navigationDestination(
					isPresented: $isSearchViewPresented,
					destination: { SearchView() }
				)
			}
			.navigationTitle("Add Friends")
		}
		.onAppear {
			suggestedFriendsViewModel.fetchData(
				from: "\(APIConstants.base_url)/api/v2/users/suggested/",
				token: authViewModel.loggedInBackendUser?.token ?? "",
				loading: true
			)
		}
	}
}
