//
//  AddFriendCard.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//



import OSLog
import SwiftUI

struct AddFriendCardSearch: View {
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SuggestedFriendsViewModel.self) private var suggestedFriendsViewModel
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AddFriendCardSearch.self)
    )
    
    @Binding var friend: SearchFriend
    let search: String?
    @State private var isLoading = false
    
    var body: some View {
        HStack {
            UserImage(url: friend.picture, height: 48, width: 48)
            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(Font.custom("Poppins-SemiBold", size: 15))
                    .foregroundColor(Color.white)
                Text(friend.username)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color("Accent"))
            }
            Spacer()
            
            if friend.friendStatus != "sent" && friend.friendStatus != "friends" {
                Button(action: {
                    sendFriendRequest()
                }) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Sending...")
                                .font(.caption)
                        }
                    } else {
                        Text("Send Request")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            } else {
                Image(systemName: "person.fill.checkmark")
                    .foregroundColor(Color("Accent"))
            }
        }
        .padding(.bottom)
    }
    
    private func sendFriendRequest() {
        guard !isLoading else { return }
        
        isLoading = true
        
        Task {
            do {
                
                let urlString = "\(APIConstants.base_url)requests/\(friend.username)/send"
                guard let url = URL(string: urlString) else {
                    logger.error("Invalid URL: \(urlString)")
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }
                
                logger.info("Sending friend request to: \(urlString)")
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue(
                    "Bearer \(authViewModel.loggedInBackendUser?.token ?? "")",
                    forHTTPHeaderField: "Authorization"
                )
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    logger.info("Response status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        // Success - update the friend status
                        await MainActor.run {
                            friend.friendStatus = "sent"
                            isLoading = false
                        }
                        
                        logger.info("Friend request sent successfully")
                        
                        // Refresh the suggested friends list
                        suggestedFriendsViewModel.fetchData(
                            from: "\(APIConstants.base_url)users/suggested/",
                            token: authViewModel.loggedInBackendUser?.token ?? "",
                            loading: false
                        )
                    } else {
                        // Handle error response
                        if let responseString = String(data: data, encoding: .utf8) {
                            logger.error("Error response: \(responseString)")
                        }
                        await MainActor.run {
                            isLoading = false
                        }
                    }
                } else {
                    logger.error("Invalid response type")
                    await MainActor.run {
                        isLoading = false
                    }
                }
                
            } catch {
                logger.error("Failed to send friend request: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
