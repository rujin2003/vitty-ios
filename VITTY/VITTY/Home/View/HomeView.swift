import SwiftUI

import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedPage = 1
    @State private var showProfileSidebar: Bool = false
    @State private var isShowingRequestView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    HStack {
                        Text(
                            selectedPage == 3 ? "Academics" :
                            selectedPage == 2 ? "Connects" :
                            "Schedule"
                        )
                        .font(Font.custom("Poppins-Bold", size: 26))
                        
                        Spacer()
                        
                        if selectedPage != 2 {
                            Button {
                                withAnimation {
                                    showProfileSidebar = true
                                }
                            } label: {
                                UserImage(
                                    url: authViewModel.loggedInBackendUser?.picture ?? "",
                                    height: 30,
                                    width: 40
                                )
                            }
                        }else{
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
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    
                    ZStack {
                        switch selectedPage {
                        case 1:
                            TimeTableView(friend: nil)
                        case 2:
                            ConnectPage()
                        case 3:
                            Academics()
                        default:
                            Text("Error Lol")
                        }
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                    
                    BottomBarView(presentTab: $selectedPage)
                        .padding(.bottom, 24)
                }
                
                // Sidebar and Overlay
                if showProfileSidebar {
                    HStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showProfileSidebar = false
                                }
                            }
                        
                        UserProfileSidebar(isPresented: $showProfileSidebar)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .transition(.move(edge: .trailing))
                            .background(Color("Background").opacity(0.95))
                        
                    }
                }
                
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
