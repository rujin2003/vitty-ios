//
//  AuthViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import Foundation
import GoogleSignIn
import OSLog

enum LoginOption {
	case googleSignIn
	case appleSignIn
}

@Observable
class AuthViewModel: NSObject, ASAuthorizationControllerDelegate {
	var loggedInFirebaseUser: User?
	var loggedInBackendUser: AppUser?
	var isLoading: Bool = false
	var error: NSError?
	let firebaseAuth = Auth.auth()
	fileprivate var currentNonce: String?
	
	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: AuthViewModel.self
		)
	)
	
	

	override init() {
		logger.info("Auth Initialization Started")
		
		do {
			try firebaseAuth.useUserAccessGroup(nil)
		}
		catch {
			logger.error("\(error)")
		}
		
		super.init()
		
		loggedInFirebaseUser = firebaseAuth.currentUser
		
		firebaseAuth.addStateDidChangeListener(authViewModelChanged)
		
		do {
			Task {
				if UserDefaults.standard.string(forKey: UserDefaultKeys.userKey) != nil {
					await signInServer(
						username: UserDefaults.standard.string(forKey: UserDefaultKeys.userKey)
							?? "",
						regNo: ""
					)
				}
			}
		}
		
		logger.info("Auth Initialization Ended")
	}

	private func authViewModelChanged(with auth: Auth, user: User?) {
		logger.info("Auth State Changed")
		DispatchQueue.main.async {
			guard user != self.loggedInFirebaseUser else { return }
			self.loggedInFirebaseUser = user
		}
	}

	func login(with loginOption: LoginOption) async throws {
		logger.info("Login Started")
		error = nil
		switch loginOption {
			case .googleSignIn:
				logger.info("Google SignIn Started")
				try await signInWithGoogle()
				logger.info("Google SignIn Ended")
			case .appleSignIn:
				logger.info("Apple SignIn Started")
				signInWithApple()
				logger.info("Apple SignIn Ended")
		}
		logger.info("Auth State Ended")
	}

	private func signInWithGoogle() async throws {
		guard let screen = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
			return
		}
		guard let window = await screen.windows.first?.rootViewController else { return }
		let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)
		let credential = GoogleAuthProvider.credential(
			withIDToken: signInResult.user.idToken?.tokenString ?? "",
			accessToken: signInResult.user.accessToken.tokenString
		)
		let authUser = try await firebaseAuth.signIn(with: credential)
		self.loggedInFirebaseUser = authUser.user
		let userDefaultsStandard = UserDefaults.standard
		userDefaultsStandard.set(authUser.user.providerID, forKey: UserDefaultKeys.providerIdKey)
		userDefaultsStandard.set(authUser.user.displayName, forKey: UserDefaultKeys.usernameKey)
		do {
			let doesUserExist = try await AuthAPIService.shared.checkUserExists(
				with: authUser.user.uid
			)
			if doesUserExist {
				loggedInBackendUser = try await AuthAPIService.shared.signInUser(
					with: AuthRequestBody(uuid: authUser.user.uid, reg_no: "", username: "")
				)
				UserDefaults.standard.set(loggedInBackendUser?.token, forKey: UserDefaultKeys.tokenKey)
				UserDefaults.standard.set(loggedInBackendUser?.username, forKey: UserDefaultKeys.userKey)
				UserDefaults.standard.set(loggedInBackendUser?.name, forKey: UserDefaultKeys.nameKey)
				UserDefaults.standard.set(loggedInBackendUser?.picture, forKey: UserDefaultKeys.imageKey)
			}
		}
		catch {
			logger.error("\(error)")
			throw error
		}
}

	private func signInWithApple() {
		let nonce = AppleSignInUtilties.randomNonceString()
		currentNonce = nonce
		let provider = ASAuthorizationAppleIDProvider()
		let request = provider.createRequest()
		request.requestedScopes = [.email, .fullName]
		request.nonce = AppleSignInUtilties.sha256(nonce)
		let authController = ASAuthorizationController(authorizationRequests: [request])
		authController.delegate = self
		authController.performRequests()
	}

	internal func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithError error: Error
	) {
		logger.error("Error signing in with Apple: \(error.localizedDescription)")
		self.error = error as NSError
	}

	internal func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) async throws {
		if let appleIdCred = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				fatalError(
					"Invalid state: A login callback was received but no login request was sent"
				)
			}
			guard let appleIdToken = appleIdCred.identityToken else {
				logger.error("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
				logger.error(
					"Unable to serialize token string from data: \(appleIdToken.debugDescription)"
				)
				return
			}
			guard let authCode = appleIdCred.authorizationCode else {
				logger.error("Unable to getch Authorization Code")
				return
			}
			guard String(data: authCode, encoding: .utf8) != nil else {
				logger.error("Unable to serialize Authorization Code")
				return
			}

			let credential = OAuthProvider.credential(
				withProviderID: "apple.com",
				idToken: idTokenString,
				rawNonce: nonce
			)
			let authUser = try await firebaseAuth.signIn(with: credential)
			self.loggedInFirebaseUser = authUser.user
			let userDefaultsStandard = UserDefaults.standard
			userDefaultsStandard.set(
				authUser.user.providerID,
				forKey: UserDefaultKeys.providerIdKey
			)
			userDefaultsStandard.set(authUser.user.displayName, forKey: UserDefaultKeys.usernameKey)
			do {
				let doesUserExist = try await AuthAPIService.shared.checkUserExists(
					with: authUser.user.uid
				)
				if doesUserExist {
					loggedInBackendUser = try await AuthAPIService.shared.signInUser(
						with: AuthRequestBody(uuid: authUser.user.uid, reg_no: "", username: "")
					)
					UserDefaults.standard.set(loggedInBackendUser?.token, forKey: UserDefaultKeys.tokenKey)
					UserDefaults.standard.set(loggedInBackendUser?.username, forKey: UserDefaultKeys.userKey)
					UserDefaults.standard.set(loggedInBackendUser?.name, forKey: UserDefaultKeys.nameKey)
					UserDefaults.standard.set(loggedInBackendUser?.picture, forKey: UserDefaultKeys.imageKey)
				}
			}
			catch {
				logger.error("\(error)")
				throw error
			}
		}
		else {
			logger.error("Error during authorization")
		}
	}

	func signOut() {
		do {
			try firebaseAuth.signOut()
			UserDefaults.resetDefaults()
		}
		catch let signOutError as NSError {
			logger.error("Error Signing Out: \(signOutError)")
		}
	}

	func signInServer(username: String, regNo: String) async {
		logger.info("Signing to Server Started")
		do {
			self.loggedInBackendUser = try await AuthAPIService.shared
				.signInUser(
					with: AuthRequestBody(
						uuid: loggedInFirebaseUser?.uid ?? "",
						reg_no: regNo,
						username: username
					)
				)
		}
		catch {
			logger.error("\(error)")
		}
		logger.info("Signing to Server Ended")
	}
}

private class AppleSignInUtilties {
	static func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: [Character] =
			Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length

		while remainingLength > 0 {
			let randoms: [UInt8] = (0..<16)
				.map { _ in
					var random: UInt8 = 0
					let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
					if errorCode != errSecSuccess {
						fatalError(
							"Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
						)
					}
					return random
				}

			randoms.forEach { random in
				if length == 0 {
					return
				}

				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}

		return result
	}
	static func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString =
			hashedData.compactMap {
				String(format: "%02x", $0)
			}
			.joined()
		return hashString
	}
}

extension UserDefaults {
	static func resetDefaults() {
		if let bundleID = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: bundleID)
		}
	}
}
