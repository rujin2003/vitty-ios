//
//  Circle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//

//TODO: the Circle doesnt have image in the endpoint , the circle members dont have thier venu status currently in the endpoint




import Foundation

struct CircleModel: Decodable {
    let circleID: String
    let circleName: String
    let circleRole: String
    
    enum CodingKeys: String, CodingKey {
        case circleID = "circle_id"
        case circleName = "circle_name"
        case circleRole = "circle_role"
    }
}

struct CircleResponse: Decodable {
    let data: [CircleModel]
}

struct CircleMember: Identifiable {
    let id = UUID()
    let picture: String
    let name: String
    let status: String
    let venue: String?
}


struct CircleUserTemp: Codable {
    let email: String
    let name: String
    let picture: String
    let username: String
    let status: String?
    let venue: String?
        
    enum CodingKeys: String, CodingKey {
        case email, name, picture, username, status, venue
    }
}

struct CircleUserResponseTemp: Codable {
    let data: [CircleUserTemp]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
// MARK: - Request Models
struct CircleRequest: Codable, Identifiable {
    let id = UUID()
    let circle_id: String
    let circle_name: String
    let from_username: String
    let to_username: String
    
    enum CodingKeys: String, CodingKey {
        case circle_id, circle_name, from_username, to_username
    }
}

struct CircleRequestResponse: Codable {
    let data: [CircleRequest]
}
