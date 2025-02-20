//
//  SuggestedFriendsViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 05/01/24.
//

import Alamofire
import Foundation
import OSLog

@Observable
class SuggestedFriendsViewModel {

	var suggestedFriends = [Friend]()
	var loading = false
	var error = false

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: SuggestedFriendsViewModel.self
		)
	)

	func fetchData(from url: String, token: String, loading: Bool) {
		self.loading = loading
		AF.request(url, method: .get, headers: ["Authorization": "Bearer \(token)"])
			.validate()
			.responseDecodable(of: [Friend].self) { response in
				switch response.result {
					case .success(let data):
						self.suggestedFriends = data
						self.loading = false
					case .failure(let error):
						self.logger.error("Error fetching data: \(error)")
						self.loading = false
						self.error.toggle()
				}
			}
	}
}
