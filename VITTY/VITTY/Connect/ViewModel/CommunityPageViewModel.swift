//
//  CommunityPageViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import Foundation
import Alamofire
import OSLog



@Observable
class CommunityPageViewModel {
    var friends = [Friend]()
    var circles = [CircleModel]()
    var loading = false
    var error = false

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommunityPageViewModel.self)
    )

    func fetchFriendsData(from url: String, token: String, loading: Bool) {
        self.loading = loading
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: FriendRaw.self) { response in
               
                switch response.result {
                    case .success(let data):
                        self.friends = data.data
                        self.loading = false
                      
                       
                    case .failure(let error):
                        self.logger.error("Error fetching data: \(error)")
                        self.loading = false
                        self.error.toggle()
                }
            }
    }
    
    func fetchCircleData(from url: String, token: String, loading: Bool) {
        self.loading = loading
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleResponse.self) { response in
            print("***********")
                print(response)
                switch response.result {
                    case .success(let data):
                        self.circles = data.data
                        self.loading = false
                    print(data.data)
                        print("Successfully fetched circles:")
                        print(data.data)
                    case .failure(let error):
                        self.logger.error("Error fetching circles: \(error)")
                        self.loading = false
                        self.error.toggle()
                }
            }
    }
}
