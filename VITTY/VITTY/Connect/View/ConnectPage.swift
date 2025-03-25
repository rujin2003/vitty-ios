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
    @State private var isShowingRequestView = false
    @State var isCircleView = false
    @State var isAddCircleFunc = false
    
    @Binding var isCreatingGroup : Bool
    
    @State private var isAddFriendsViewPresented = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            
            
            VStack(spacing: 0) {
                
                HStack {
                    AcademicsTabButton(title: "Friends", isActive: selectedTab == 0) {
                        selectedTab = 0
                    }
                    AcademicsTabButton(title: "Circles", isActive: selectedTab == 1) {
                       
                        selectedTab = 1
                        isCircleView = true
                 
                    }
                }
                .padding(.top,20)
              
                TabView(selection: $selectedTab) {
                    FriendsView()
                        .tag(0)
                    CirclesView(isCreatingGroup: $isCreatingGroup)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            if isCircleView == false {
                Button(action: {
                    isShowingRequestView.toggle()

                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundColor(.white)
                }
                .navigationDestination(
                    isPresented: $isShowingRequestView,
                    destination: {
                        AddFriendsView()
                    }
                ).offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            } else{
                Button(action: {
                    isAddCircleFunc.toggle()

                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundColor(.white)
                }
               .offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            }
            
        }.sheet(isPresented: $isAddCircleFunc){
            VStack{
                Text("Hello sir")
            }
        }
        
        .onAppear {
            print()
            print()
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
