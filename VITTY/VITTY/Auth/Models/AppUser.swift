//
//  AppUser.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import Foundation

class AppUser: Codable {
	let name: String
	let picture: String
	let role: String
	let token: String
	let username: String
	
	init(name: String, picture: String, role: String, token: String, username: String) {
		self.name = name
		self.picture = picture
		self.role = role
		self.token = token
		self.username = username
	}
}
