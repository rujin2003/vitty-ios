//
//  FreindRequestModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/4/25.
//

import Foundation
import SwiftUI
import OSLog

// MARK: new implementation for freindrequests ,new view model need to optimize the code removing the old one


@Observable
class RequestsViewModel {
    var friendRequests: [FriendRequest] = []
    var isLoading = false
    var errorMessage: String?
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: RequestsViewModel.self)
    )
    
   
    func fetchFriendRequests(token: String, loading: Bool = true) {
        guard !token.isEmpty else {
            logger.error("No token provided")
            return
        }
        
        if loading {
            isLoading = true
        }
        errorMessage = nil
        
        Task {
            do {
                let urlString = "\(APIConstants.base_url)requests/"
                guard let url = URL(string: urlString) else {
                    logger.error("Invalid URL: \(urlString)")
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Invalid URL"
                    }
                    return
                }
                
                logger.info("Fetching friend requests from: \(urlString)")
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    logger.info("Response status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                      
                        if let responseString = String(data: data, encoding: .utf8) {
                            logger.info("Response: \(responseString)")
                            
                            if responseString.trimmingCharacters(in: .whitespacesAndNewlines) == "null" ||
                               responseString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                await MainActor.run {
                                    self.friendRequests = []
                                    self.isLoading = false
                                }
                                return
                            }
                        }
                        
                        let decoder = JSONDecoder()
                        let requests = try decoder.decode([FriendRequest].self, from: data)
                        
                        await MainActor.run {
                            self.friendRequests = requests
                            self.isLoading = false
                        }
                        
                        logger.info("Successfully fetched \(requests.count) friend requests")
                    } else {
                        let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
                        logger.error("Error fetching friend requests: \(errorResponse)")
                        await MainActor.run {
                            self.isLoading = false
                            self.errorMessage = "Failed to fetch friend requests"
                        }
                    }
                }
            } catch {
                logger.error("Failed to fetch friend requests: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Accept Friend Request
    func acceptFriendRequest(username: String, token: String) async -> Bool {
        guard !token.isEmpty else {
            logger.error("No token provided")
            return false
        }
        
        do {
            let urlString = "\(APIConstants.base_url)requests/\(username)/accept/"
            guard let url = URL(string: urlString) else {
                logger.error("Invalid URL: \(urlString)")
                return false
            }
            
            logger.info("Accepting friend request for: \(username)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Accept request response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    logger.info("Friend request accepted successfully")
                    
                   
                    await MainActor.run {
                        self.friendRequests.removeAll { $0.from.username == username }
                    }
                    
                    return true
                } else {
                    let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
                    logger.error("Failed to accept friend request: \(errorResponse)")
                    return false
                }
            }
        } catch {
            logger.error("Failed to accept friend request: \(error.localizedDescription)")
        }
        
        return false
    }
    
    // MARK: - Decline Friend Request
    func declineFriendRequest(username: String, token: String) async -> Bool {
        guard !token.isEmpty else {
            logger.error("No token provided")
            return false
        }
        
        do {
            let urlString = "\(APIConstants.base_url)requests/\(username)/decline/"
            guard let url = URL(string: urlString) else {
                logger.error("Invalid URL: \(urlString)")
                return false
            }
            
            logger.info("Declining friend request for: \(username)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Decline request response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    logger.info("Friend request declined successfully")
                    
                   
                    await MainActor.run {
                        self.friendRequests.removeAll { $0.from.username == username }
                    }
                    
                    return true
                } else {
                    let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
                    logger.error("Failed to decline friend request: \(errorResponse)")
                    return false
                }
            }
        } catch {
            logger.error("Failed to decline friend request: \(error.localizedDescription)")
        }
        
        return false
    }
}
