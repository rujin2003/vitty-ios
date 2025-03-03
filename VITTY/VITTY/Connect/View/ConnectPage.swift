//
//  Freinds.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI

struct ConnectPage: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(FriendRequestViewModel.self) private var friendRequestViewModel
    
    @State private var isAddFriendsViewPresented = false
    @State private var selectedTab: ConnectTab = .friends
    
    enum ConnectTab {
        case friends
        case circles
    }
    
    var body: some View {
    
            ZStack {
                BackgroundView()
                VStack {
                    
                    HStack(spacing: 0) {
                        TabButton(title: "Friends", isSelected: selectedTab == .friends) {
                            selectedTab = .friends
                        }
                        
                        TabButton(title: "Circles", isSelected: selectedTab == .circles) {
                            selectedTab = .circles
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: .constant(""))
                            .font(Font.custom("Poppins-Regular", size: 16))
                        
                        Button(action: {
                            // Clear search field
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color("Secondary").opacity(0.5))
                    .cornerRadius(10)
                    .padding()
                    
                    // Filter Pills (shown only in Friends tab)
                    if selectedTab == .friends {
                        HStack {
                            FilterPill(title: "Available", isSelected: true)
                            
                            FilterPill(title: "View All", isSelected: false)
                            
                            Spacer()
                        }
                        .padding(.horizontal).padding(.bottom)
                    }
                    
                   
                    if selectedTab == .friends {
                        FriendsView()
                    } else {
                        CirclesView()
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if !(friendRequestViewModel.error) && !(friendRequestViewModel.loading) {
                            Button {
                                isAddFriendsViewPresented.toggle()
                            } label: {
                                HStack(spacing: 2) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(.white)
                                    
                                    if friendRequestViewModel.requests.count > 0 {
                                        Text("\(friendRequestViewModel.requests.count)")
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .padding(4)
                                            .foregroundStyle(.white)
                                            .background(.red)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
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

// Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(Font.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.white)
                
                if isSelected {
                    Rectangle()
                        .frame(height: 3)
                        .foregroundColor(.white)
                } else {
                    Rectangle()
                        .frame(height: 3)
                        .foregroundColor(.clear)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(Font.custom("Poppins-Regular", size: 14))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color("Accent"), lineWidth: isSelected ? 2 : 0)
                    .background(
                        Capsule()
                            .fill(Color("Secondary").opacity(0.5))
                    )
            )
    }
}

