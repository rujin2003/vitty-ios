//
//  CommunityPageViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/01/24.
//

import Alamofire
import Foundation
import OSLog

@Observable
class CommunityPageViewModel {

	var friends = [Friend]()
	var loading = false
	var error = false

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: CommunityPageViewModel.self
		)
	)

	func fetchData(from url: String, token: String, loading: Bool) {
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
}
