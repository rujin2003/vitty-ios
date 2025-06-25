import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedPage = 1
    @State private var showProfileSidebar: Bool = false
    @State private var isCreatingGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text(
                            selectedPage == 3 ? "Academics" :
                            selectedPage == 2 ? "Connects" :
                            "Schedule"
                        )
                        .font(Font.custom("Poppins-Bold", size: 26))

                        Spacer()

                        if selectedPage != 2 {
                            ZStack {
                                if !showProfileSidebar {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.8
                                                                
                                                                )) {
                                            showProfileSidebar = true
                                        }
                                    } label: {
                                        UserImage(
                                            url: authViewModel.loggedInBackendUser?.picture ?? "",
                                            height: 30,
                                            width: 40
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    // Main Content
                    ZStack {
                        switch selectedPage {
                        case 1:
                            TimeTableView(friend: nil,isFriendsTimeTable: false)
                        case 2:
                            ConnectPage(isCreatingGroup: $isCreatingGroup)
                        case 3:
                            Academics()
                        default:
                            Text("Error")
                        }
                    }
                    .padding(.top, 4)

                    Spacer()

                    // Bottom Navigation Bar
                    BottomBarView(presentTab: $selectedPage)
                        .padding(.bottom, 24)
                }

             
                if showProfileSidebar {
                    
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showProfileSidebar = false
                            }
                        }

                    // Sidebar
                    HStack {
                        Spacer()
                        UserProfileSidebar(isPresented: $showProfileSidebar)
                            .frame(width: UIScreen.main.bounds.width * 0.75)
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

