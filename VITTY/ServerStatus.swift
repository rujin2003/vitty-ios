//
//  ServerStatus.swift
//  VITTY
//
//  Created by Rujin Devkota on 8/4/25.
//
import Foundation
import Alamofire
import SwiftUI
import OSLog

@Observable
class ServerStatusManager {
    var isServerDown = false
    var isCheckingServer = false
    var showMaintenanceAlert = false
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ServerStatusManager.self)
    )
    
    func shouldCheckServerStatus(for error: AFError) -> Bool {
        if let responseCode = error.responseCode {
            return responseCode >= 500
        }
        
        if case .sessionTaskFailed(let sessionError) = error {
            let nsError = sessionError as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorTimedOut,
                     NSURLErrorCannotFindHost,
                     NSURLErrorCannotConnectToHost:
                    return true
                default:
                    return false
                }
            }
        }
        
        return false
    }

    func checkServerStatus(completion: @escaping (Bool) -> Void) {
        isCheckingServer = true
        let url = APIConstants.base_url

        let request = AF.request(url, method: .head)
            .validate(statusCode: 200..<400)
            .response { response in
                DispatchQueue.main.async {
                    self.isCheckingServer = false

                    switch response.result {
                    case .success:
                        self.isServerDown = false
                        self.showMaintenanceAlert = false
                        completion(true)

                    case .failure(_):
                        let isInternetAvailable = NetworkReachabilityManager()?.isReachable ?? false
                        
                        if isInternetAvailable {
                            self.logger.warning("Server unreachable or returned unexpected status")
                            self.isServerDown = true
                            self.showMaintenanceAlert = true
                        } else {
                            self.logger.warning("No internet connection")
                            self.isServerDown = true
                            self.showMaintenanceAlert = true
                        }

                        completion(false)
                    }
                }
            }
    }
    
    func handleServerError(_ error: AFError, completion: @escaping (Bool) -> Void) {
        if shouldCheckServerStatus(for: error) {
            logger.warning("API call failed with server error, checking server status")
            checkServerStatus(completion: completion)
        } else {
            logger.info("API call failed but not due to server issues")
            completion(false)
        }
    }
    
    func hideMaintenanceAlert() {
        showMaintenanceAlert = false
    }
    
    func retryServerCheck(completion: @escaping (Bool) -> Void) {
        checkServerStatus(completion: completion)
    }
}

struct MaintenanceAlertView: View {
    @Binding var isPresented: Bool
    let onRetry: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                        onContinue()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.white)
                            .font(.system(size: 32))
                    )
                
                Text("Server Maintenance")
                    .font(.custom("Poppins-SemiBold", size: 24))
                    .foregroundColor(.white)
                
                Text("The server is currently under maintenance. Some features may be temporarily unavailable.")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: {
                        onRetry()
                    }) {
                        Text("Retry")
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isPresented = false
                        onContinue()
                    }) {
                        Text("Continue")
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                Text("Thank you for your patience")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding(30)
            .background(Color("Background"))
            .cornerRadius(20)
            .padding(.horizontal, 30)
        }
    }
}

