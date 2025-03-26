//
//  InsideCircle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/26/25.


import SwiftUI
import SwiftUI

struct InsideCircle: View {
    var groupCode: String
    @State var searchText: String = ""
    @Environment(CommunityPageViewModel.self) private var communityPageViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Circle")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                   
                }) {
                    Image("leave")
                       
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            SearchBar(searchText: $searchText)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height: 8)
                HStack {
                    Text("Dholakpur Squad")
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Text(groupCode)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color("Accent"))
                }
                Spacer().frame(height: 5)
                HStack {
                    HStack {
                        Image("inclass").resizable().frame(width: 18, height: 18)
                        Text("3 busy")
                            .foregroundStyle(Color("Accent"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                    Spacer().frame(width: 10)
                    HStack {
                        Image("available").resizable().frame(width: 18, height: 18)
                        Text("2 available")
                            .foregroundStyle(Color("Accent"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("Secondary"))
                    .cornerRadius(12)
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
                        ForEach(communityPageViewModel.circleMembers, id: \ .username) { member in
                            InsideCircleRow(
                                picture: member.picture,
                                name: member.name,
                                status: "free",
                                venue: "318"
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            Spacer()
        }
        .background(Color("Background").edgesIgnoringSafeArea(.all))
        .onAppear {
            communityPageViewModel.fetchCircleMemberData(
                from: "\(APIConstants.base_url)circles/\(groupCode)",
                token: authViewModel.loggedInBackendUser?.token ?? "",
                loading: true
            )
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)

    }
}
