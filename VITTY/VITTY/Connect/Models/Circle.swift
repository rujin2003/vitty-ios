//
//  Circle.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//

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
