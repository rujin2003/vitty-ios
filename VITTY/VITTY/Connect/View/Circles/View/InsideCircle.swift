//
//  InsideCircle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/26/25.

import SwiftUI

struct LeaveCircleAlert: View {
    let circleName: String
    let onCancel: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Leave circle?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to leave \(circleName)?")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onLeave) {
                        Text("Leave")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct CircleMenuView: View {
    let circleName: String
    let onLeaveGroup: () -> Void
    let onGroupRequests: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Button(action: {
                    onCancel()
                    onLeaveGroup()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Leave Group")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color("Background"))
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
               
                
                
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Background"))
                }
            }
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct InsideCircle: View {
    var circleName : String
    var groupCode: String
    @State var searchText: String = ""
    @State var showLeaveAlert: Bool = false
    @State var showCircleMenu: Bool = false
    @State var  showGroupRequests : Bool = false
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showQRCode: Bool = false
    
  
    private var busyCount: Int {
        communityPageViewModel.circleMembers.filter {
            $0.status != nil && $0.status != "available" && $0.status != "free"
        }.count
    }
    
    private var availableCount: Int {
        communityPageViewModel.circleMembers.filter {
            $0.status == nil || $0.status == "available" || $0.status == "free"
        }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white).font(.title2)
                }
                Spacer()
                Text("Circle")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showCircleMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
            }
            .padding()
            
            SearchBar(searchText: $searchText)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height: 8)
                HStack {
                    Text("\(circleName)")
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    
                }
                Spacer().frame(height: 5)
                HStack {
                    // Dynamic busy count
                    if busyCount > 0 {
                        HStack {
                            Image("inclass").resizable().frame(width: 18, height: 18)
                            Text("\(busyCount) busy")
                                .foregroundStyle(Color("Accent"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Secondary"))
                        .cornerRadius(12)
                        
                        Spacer().frame(width: 10)
                    }
                    
                    // Dynamic available count
                    if availableCount > 0 {
                        HStack {
                            Image("available").resizable().frame(width: 18, height: 18)
                            Text("\(availableCount) available")
                                .foregroundStyle(Color("Accent"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("Secondary"))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                 
                    Button(action: {
                        showQRCode = true
                        print("QR Code tapped")
                    }) {
                        Image(systemName: "qrcode")
                            .foregroundColor(Color("Accent"))
                            .font(.system(size: 20))
                            .padding(8)
                            .background(Color("Secondary"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            if communityPageViewModel.loadingCircleMembers {
                ProgressView("Loading...")
                    .padding()
            } else if communityPageViewModel.errorCircleMembers {
                Text("Failed to load members.")
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(communityPageViewModel.circleMembers, id: \.username) { member in
                            InsideCircleRow(
                                picture: member.picture,
                                name: member.name,
                                status: member.status ?? "free",
                                venue: member.venue ?? "available"
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            Spacer()
        }
        .background(Color("Background").edgesIgnoringSafeArea(.all)).sheet(isPresented: $showGroupRequests, content: {
            CircleRequestsView()
        })
        .onAppear {
            communityPageViewModel.fetchCircleMemberData(
                from: "\(APIConstants.base_url)circles/\(groupCode)",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }
        .overlay(
            Group {
                if showLeaveAlert {
                    LeaveCircleAlert(circleName: "\(circleName)", onCancel: {
                        showLeaveAlert = false
                    }, onLeave: {
                        let url = "\(APIConstants.base_url)circles/\(groupCode)/leave"
                        let token = authViewModel.loggedInBackendUser?.token ?? ""

                        communityPageViewModel.leaveCircle(from: url, token: token)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showLeaveAlert = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                }
                
                if showCircleMenu {
                    CircleMenuView(
                        circleName: circleName,
                        onLeaveGroup: {
                            showLeaveAlert = true
                        },
                        onGroupRequests: {
                            showGroupRequests = true
                            print("Navigate to Circle Requests")
                        },
                        onCancel: {
                            showCircleMenu = false
                        }
                    )
                }
                if showQRCode {
                                   QRCodeModalView(
                                       groupCode: groupCode,
                                       circleName: circleName,
                                       onDismiss: {
                                           showQRCode = false
                                       }
                                   )
                               }
            }
        )
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
