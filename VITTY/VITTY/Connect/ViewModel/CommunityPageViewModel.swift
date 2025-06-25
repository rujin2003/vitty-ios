//
//  CommunityPageViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//
//

import Foundation
import Alamofire
import OSLog

@Observable
class CommunityPageViewModel {
    var friends = [Friend]()
    var circles = [CircleModel]()
    var circleRequests = [CircleRequest]()
    
    var loadingFreinds = false
    var loadingCircle = false
    var loadingCircleMembers = false
    var loadingCircleRequests = false
    var loadingRequestAction = false
    
    var errorFreinds = false
    var errorCircle = false
    var errorCircleMembers = false
    var errorCircleRequests = false
    
    var circleMembers = [CircleUserTemp]()
    
    var circleMembersDict: [String: [CircleUserTemp]] = [:]
    var loadingCircleMembersDict: [String: Bool] = [:]

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommunityPageViewModel.self)
    )

    func fetchFriendsData(from url: String, token: String, loading: Bool = false) {
       
        if loading || friends.isEmpty {
            self.loadingFreinds = true
        }
        
       
        self.errorFreinds = false
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: FriendRaw.self) { response in
                DispatchQueue.main.async {
                    self.loadingFreinds = false
                    
                    switch response.result {
                    case .success(let data):
                        self.friends = data.data
                        self.errorFreinds = false
                        
                    case .failure(let error):
                        self.logger.error("Error fetching friends: \(error)")
                      
                        if self.friends.isEmpty {
                            self.errorFreinds = true
                        }
                    }
                }
            }
    }
    
    //MARK: Circle DATA
    
    func fetchCircleData(from url: String, token: String, loading: Bool = false) {
       
        if loading || circles.isEmpty {
            self.loadingCircle = true
        }
        
      
        self.errorCircle = false
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleResponse.self) { response in
                DispatchQueue.main.async {
                    self.loadingCircle = false
                    
                    switch response.result {
                    case .success(let data):
                        self.circles = data.data
                        self.errorCircle = false
                        print("Successfully fetched circles: \(data.data)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circles: \(error)")
                      
                        if self.circles.isEmpty {
                            self.errorCircle = true
                        }
                    }
                }
            }
    }
    
    // MARK: - Circle Requests
    
    func fetchCircleRequests(token: String, loading: Bool = false) {
        if loading || circleRequests.isEmpty {
            self.loadingCircleRequests = true
        }
        
        self.errorCircleRequests = false
        
        let url = "\(APIConstants.base_url)circles/requests/received"
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleRequestResponse.self) { response in
                DispatchQueue.main.async {
                    self.loadingCircleRequests = false
                    
                    switch response.result {
                    case .success(let data):
                        self.circleRequests = data.data
                        self.errorCircleRequests = false
                        self.logger.info("Successfully fetched circle requests: \(data.data.count) requests")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle requests: \(error)")
                        if self.circleRequests.isEmpty {
                            self.errorCircleRequests = true
                        }
                    }
                }
            }
    }
    
    func acceptCircleRequest(circleId: String, token: String, completion: @escaping (Bool) -> Void) {
        self.loadingRequestAction = true
        
        let url = "\(APIConstants.base_url)circles/acceptRequest/\(circleId)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingRequestAction = false
                    
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully accepted circle request for circle: \(circleId)")
                        self.circleRequests.removeAll { $0.circle_id == circleId }
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error accepting circle request: \(error)")
                        completion(false)
                    }
                }
            }
    }
    
    func declineCircleRequest(circleId: String, token: String, completion: @escaping (Bool) -> Void) {
        self.loadingRequestAction = true
        
        let url = "\(APIConstants.base_url)circles/declineRequest/\(circleId)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingRequestAction = false
                    
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully declined circle request for circle: \(circleId)")
                        self.circleRequests.removeAll { $0.circle_id == circleId }
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error declining circle request: \(error)")
                        completion(false)
                    }
                }
            }
    }
  
    func fetchCircleMemberData(from url: String, token: String, loading: Bool = false, circleID: String? = nil) {
        if let circleID = circleID {
            if loading || circleMembersDict[circleID]?.isEmpty != false {
                self.loadingCircleMembersDict[circleID] = true
            }
        } else {
            if loading || circleMembers.isEmpty {
                self.loadingCircleMembers = true
            }
        }
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        if let circleID = circleID {
                            self.circleMembersDict[circleID] = data.data
                            self.loadingCircleMembersDict[circleID] = false
                        } else {
                            self.circleMembers = data.data
                            self.loadingCircleMembers = false
                        }
                        print("Successfully fetched circle members: \(data.data)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle members: \(error)")
                        
                        if let circleID = circleID {
                            self.loadingCircleMembersDict[circleID] = false
                        } else {
                            self.loadingCircleMembers = false
                            if self.circleMembers.isEmpty {
                                self.errorCircleMembers = true
                            }
                        }
                    }
                }
            }
    }
    
    //MARK : Circle Leave
    func fetchCircleLeave(from url: String, token: String, loading: Bool = false) {
        if loading {
            self.loadingCircleMembers = true
        }
        
        AF.request(url, method: .get, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseDecodable(of: CircleUserResponseTemp.self) { response in
                DispatchQueue.main.async {
                    self.loadingCircleMembers = false
                    
                    switch response.result {
                    case .success(let data):
                        self.circleMembers = data.data
                        print("Successfully fetched circle members after leave: \(data.data)")
                        
                    case .failure(let error):
                        self.logger.error("Error fetching circle members: \(error)")
                        if self.circleMembers.isEmpty {
                            self.errorCircleMembers = true
                        }
                    }
                }
            }
    }
    
    //MARK: leave Circle
    
    func leaveCircle(from url: String, token: String) {
        self.loadingCircleMembers = true
        
        AF.request(url, method: .delete, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    self.loadingCircleMembers = false
                    
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any], let detail = json["detail"] as? String {
                            self.logger.info("Success: \(detail)")
                        }
                        
                    case .failure(let error):
                        self.logger.error("Error leaving circle: \(error)")
                        self.errorCircleMembers = true
                    }
                }
            }
    }
    
    // MARK: Helper methods for circle members
    
    func circleMembers(for circleID: String) -> [CircleUserTemp] {
        return circleMembersDict[circleID] ?? []
    }
    
    func isLoadingCircleMembers(for circleID: String) -> Bool {
        return loadingCircleMembersDict[circleID] ?? false
    }
    
    func clearCircleMembers(for circleID: String) {
        circleMembersDict.removeValue(forKey: circleID)
        loadingCircleMembersDict.removeValue(forKey: circleID)
    }
    
    // MARK: - Group Creation
       
    func createCircle(name: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name
        let url = "\(APIConstants.base_url)circles/create/\(encodedName)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .responseJSON { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        if let json = data as? [String: Any],
                           let circleId = json["circle_id"] as? String {
                            self.logger.info("Successfully created circle: \(circleId)")
                            completion(.success(circleId))
                        } else {
                          
                            if let json = data as? [String: Any],
                               let dataDict = json["data"] as? [String: Any],
                               let circleId = dataDict["id"] as? String {
                                self.logger.info("Successfully created circle: \(circleId)")
                                completion(.success(circleId))
                            } else {
                                let error = NSError(domain: "CreateCircleError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                                completion(.failure(error))
                            }
                        }
                        
                    case .failure(let error):
                        self.logger.error("Error creating circle: \(error)")
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func sendCircleInvitation(circleId: String, username: String, token: String, completion: @escaping (Bool) -> Void) {
        let url = "\(APIConstants.base_url)circles/sendRequest/\(circleId)/\(username)"
        
        AF.request(url, method: .post, headers: ["Authorization": "Token \(token)"])
            .validate()
            .response { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success:
                        self.logger.info("Successfully sent invitation to \(username) for circle \(circleId)")
                        completion(true)
                        
                    case .failure(let error):
                        self.logger.error("Error sending invitation to \(username): \(error)")
                        completion(false)
                    }
                }
            }
    }
    
    func sendMultipleInvitations(circleId: String, usernames: [String], token: String, completion: @escaping ([String: Bool]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results: [String: Bool] = [:]
        
        for username in usernames {
            dispatchGroup.enter()
            
            sendCircleInvitation(circleId: circleId, username: username, token: token) { success in
                results[username] = success
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
    
    // MARK: - Refresh Methods
    
    func refreshAllData(token: String, username: String) {
       
        fetchFriendsData(
            from: "\(APIConstants.base_url)friends/\(username)/",
            token: token,
            loading: false
        )
        
      
        fetchCircleData(
            from: "\(APIConstants.base_url)circles",
            token: token,
            loading: false
        )
        
       
        fetchCircleRequests(token: token, loading: false)
    }
}
