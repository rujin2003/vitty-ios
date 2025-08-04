//
//  APIConstants.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 09/09/2023.
//


import Foundation


struct APIConstants {
	static let base_url = "https://api-vitty.dscvit.com/api/v2/"
    
    static let base_urlv3 = "https://api-vitty.dscvit.com/api/v3/"
    
    static let createCircle = "circles/create/"
    static let sendRequest = "circles/sendRequest/"
    static let acceptRequest = "circles/acceptRequest/"
    static let declineRequest = "circles/declineRequest/"
    static let circleRequests = "circles/requests/received"
    static let friends = "friends"
}
