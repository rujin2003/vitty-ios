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
                    } else {
                        if communityPageViewModel.loading {
                            Spacer()
                            ProgressView()
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(communityPageViewModel.friends, id: \.username) { friend in
                                        NavigationLink(destination: TimeTableView(friend: friend)) {
                                            FriendRow(friend: friend)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .safeAreaPadding(.bottom, 100)
                            .refreshable {
                                communityPageViewModel.fetchData(
                                    from: "\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                                    token: authViewModel.loggedInBackendUser?.token ?? "",
                                    loading: false
                                )
                            }
                        }
                    }
                }
            }
            .toolbar {
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
                                    from: "\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                                    token: authViewModel.loggedInBackendUser?.token ?? "",
                                    loading: true
                                )
                            },
                            content: FriendRequestView.init
                        )
                }
            }
        }
        .onAppear {
            communityPageViewModel.fetchData(
                from: "\(APIConstants.base_url)/api/v2/friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
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
