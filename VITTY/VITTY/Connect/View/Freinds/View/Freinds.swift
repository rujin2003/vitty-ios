//
//  Freinds.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//
import SwiftUI
struct FriendsView: View {
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        if communityPageViewModel.error {
            VStack {
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
        } else if communityPageViewModel.loading {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
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
