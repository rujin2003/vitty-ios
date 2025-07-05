//
//  FreindRequestModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/4/25.
//

import Foundation

// MARK: - Friend Request Models
struct FriendRequest: Codable, Identifiable {
    let id = UUID()
    let from: RequestUser
    
    enum CodingKeys: String, CodingKey {
        case from
    }
}

struct RequestUser: Codable {
    let username: String
    let name: String
    let picture: String
    let friendStatus: String
    let friendsCount: Int
    let mutualFriendsCount: Int
    let currentStatus: CurrentStatus
    
    enum CodingKeys: String, CodingKey {
        case username, name, picture
        case friendStatus = "friend_status"
        case friendsCount = "friends_count"
        case mutualFriendsCount = "mutual_friends_count"
        case currentStatus = "current_status"
    }
}

