//
//  CommunityView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import SwiftUI

struct ConnectPage: View {

	@Environment(AuthViewModel.self) private var authViewModel
	@Environment(CommunityPageViewModel.self) private var communityPageViewModel
	@Environment(FriendRequestViewModel.self) private var friendRequestViewModel

	@State private var isShowingRequestView = false
	@State private var isAddFriendsViewPresented = false

	var body: some View {
		NavigationStack {
			ZStack {
				BackgroundView()
				VStack(alignment: .center) {
					if communityPageViewModel.error {
						Spacer()
						Text("No Friends?")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-SemiBold", size: 18))
							.foregroundColor(Color.white)
						Text("Add your friends and see their timetable")
							.multilineTextAlignment(.center)
							.font(Font.custom("Poppins-Regular", size: 12))
							.foregroundColor(Color.white)
						Spacer()
					}
					else {
						if communityPageViewModel.loading {
							Spacer()
							ProgressView()
							Spacer()
						}
						else {
							List(communityPageViewModel.friends, id: \.username) { friend in
								NavigationLink {
									TimeTableView(friend: friend)
								} label: {
									HStack {
										UserImage(url: friend.picture, height: 48, width: 48)
										VStack(alignment: .leading) {
											Text(friend.name)
												.font(Font.custom("Poppins-SemiBold", size: 15))
												.foregroundColor(Color.white)
											if friend.currentStatus.status == "free" {
												Text("Not in a class right now")
													.font(Font.custom("Poppins-Regular", size: 14))
													.foregroundColor(Color("Accent"))
											}
											else {
												Text(friend.currentStatus.class ?? "")
													.font(Font.custom("Poppins-Regular", size: 14))
													.foregroundColor(Color("Accent"))
											}
										}
										Spacer()
										VStack {
											Text("NOW")
												.font(Font.custom("Poppins-Regular", size: 14))
												.foregroundColor(Color.white)
											if friend.currentStatus.status == "free" {
												Text(friend.currentStatus.status.capitalized)
													.font(Font.custom("Poppins-SemiBold", size: 16))
													.foregroundColor(Color.white)
											}
											else {
												Text(friend.currentStatus.venue ?? "-")
													.font(Font.custom("Poppins-SemiBold", size: 16))
													.foregroundColor(Color.white)
											}
										}
									}
									.padding(.bottom)
								}
								
								.listRowBackground(
									RoundedRectangle(cornerRadius: 15)
										.fill(Color("Secondary"))
										.padding(.bottom)
								)
								.listRowSeparator(.hidden)
							}
							.scrollContentBackground(.hidden)
							.refreshable {
								communityPageViewModel.fetchData(
									from:
										"\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
									token: authViewModel.loggedInBackendUser?.token ?? "",
									loading: false
								)
							}
							Spacer()
						}
					}
				}
			}
			.toolbar {
				Group {
					if !(friendRequestViewModel.error) && !(friendRequestViewModel.loading) {

						Text("\(friendRequestViewModel.requests.count) req")
							.font(Font.custom("Poppins-Regular", size: 12))
							.padding(4)
							.foregroundStyle(.white)
							.background(.red)
							.clipShape(RoundedRectangle(cornerRadius: 4))
							.onTapGesture {
								isAddFriendsViewPresented.toggle()
							}
							.sheet(
								isPresented: $isAddFriendsViewPresented,
								onDismiss: {
									communityPageViewModel.fetchData(
										from:
											"\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
										token: authViewModel.loggedInBackendUser?.token ?? "",
										loading: true
									)
								},
								content: FriendRequestView.init
							)

					}
				}
				Button(action: {
					isShowingRequestView.toggle()

				}) {
					Image(systemName: "person.fill.badge.plus")
						.foregroundColor(.white)
				}
				.navigationDestination(
					isPresented: $isShowingRequestView,
					destination: { AddFriendsView() }
				)

			}
			.navigationTitle("Connect")
		}
		.onAppear {
			communityPageViewModel.fetchData(
				from:
					"\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
				token: authViewModel.loggedInBackendUser?.token ?? "",
				loading: true
			)
			friendRequestViewModel.fetchFriendRequests(
				from: URL(string: "\(APIConstants.base_url)/api/v2/requests/")!,
				authToken: authViewModel.loggedInBackendUser?.token ?? "",
				loading: true
			)
		}
	}
}
