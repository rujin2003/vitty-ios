//
//  Freinds.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.



import SwiftUI

enum SheetType: Identifiable {
    case addCircleOptions
    case createGroup
    case joinGroup
    
    var id: Int {
        switch self {
        case .addCircleOptions: return 0
        case .createGroup: return 1
        case .joinGroup: return 2
        }
    }
}

struct ConnectPage: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(FriendRequestViewModel.self) private var friendRequestViewModel
    @State private var isShowingRequestView = false
    @State var isCircleView = false
    @State private var activeSheet: SheetType?
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isCreatingGroup : Bool
    
    @State private var isAddFriendsViewPresented = false
    @State private var selectedTab = 0
    @State private var hasLoadedInitialData = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                
                HStack {
                    AcademicsTabButton(title: "Friends", isActive: selectedTab == 0) {
                        selectedTab = 0
                        isCircleView = false
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
                )
                .offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            } else {
                Button(action: {
                    activeSheet = .addCircleOptions
                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundColor(.white)
                }
                .offset(x: UIScreen.main.bounds.width*0.4228, y: UIScreen.main.bounds.height*0.38901*(-1))
            }
        }
       
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .addCircleOptions:
                AddCircleOptionsView(activeSheet: $activeSheet)
            case .createGroup:
                CreateGroup(groupCode: .constant(""), token:authViewModel.loggedInBackendUser?.token ?? "" )
            case .joinGroup:
                JoinGroup(groupCode: .constant(""))
            }
        }
        .onAppear {
            
            let shouldShowLoading = !hasLoadedInitialData
            
            
            if communityPageViewModel.friends.isEmpty || !hasLoadedInitialData {
                communityPageViewModel.fetchFriendsData(
                    from: "\(APIConstants.base_url)friends/\(authViewModel.loggedInBackendUser?.username ?? "")/",
                    token: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            if communityPageViewModel.circles.isEmpty || !hasLoadedInitialData {
                communityPageViewModel.fetchCircleData(
                    from: "\(APIConstants.base_url)circles",
                    token: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            if communityPageViewModel.circleRequests.isEmpty || !hasLoadedInitialData {
                friendRequestViewModel.fetchFriendRequests(
                    from: URL(string: "\(APIConstants.base_url)requests/")!,
                    authToken: authViewModel.loggedInBackendUser?.token ?? "",
                    loading: shouldShowLoading
                )
            }
            
            hasLoadedInitialData = true
        }
    }
}

struct AddCircleOptionsView: View {
    @Binding var activeSheet: SheetType?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("Background")
            HStack(spacing: 40) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        activeSheet = .joinGroup
                    }
                }) {
                    VStack {
                        Image("joingroup")
                            .resizable()
                            .frame(width: 55, height: 55)
                        Text("Join Group")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white)
                    }
                }
                
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        activeSheet = .createGroup
                    }
                }) {
                    VStack {
                        Image("creategroup")
                            .resizable()
                            .frame(width: 55, height: 55)
                        Text("Create Group")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.top, 10)
        }
        .background(Color("Background"))
        .presentationDetents([.height(150)])
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
