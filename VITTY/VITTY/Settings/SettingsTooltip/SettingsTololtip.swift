//
//  SettingsTololtip.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/16/25.
//



import SwiftUI
import TipKit

// MARK: - Settings Tips Definition
struct SettingsTip {
    let id: Int
    let title: String
    let message: String
    let isLast: Bool
}

// MARK: - Settings Tip Manager
class SettingsTipManager: ObservableObject {
    @Published var currentTipIndex = 0
    @Published var showTips = false
    @Published var hasCompletedSettingsOnboarding = false
    
    private var hasSeenSettingsOnboardingKey: String { "hasSeenSettingsOnboarding" }
    
    let tips: [SettingsTip] = [
        SettingsTip(
            id: 1,
            title: "Timetable Sync",
            message: "Keep your timetable up-to-date by syncing with the server. You can also update your schedule online through the web portal.",
            isLast: false
        ),
        SettingsTip(
            id: 2,
            title: "Saturday Classes",
            message: "Customize your Saturday schedule by copying classes from any weekday. Perfect for make-up classes or special schedules.",
            isLast: false
        ),
        SettingsTip(
            id: 3,
            title: "Notifications",
            message: "Enable notifications to get timely reminders about your upcoming classes and assignments.",
            isLast: false
        ),
        SettingsTip(
            id: 4,
            title: "Account Management",
            message: "Manage your account settings and data. You can delete your account and all associated data if needed.",
            isLast: true
        )
    ]
    
    init() {
        checkOnboardingStatus()
    }
    
    var currentTip: SettingsTip? {
        guard currentTipIndex < tips.count else { return nil }
        return tips[currentTipIndex]
    }
    
    func checkOnboardingStatus() {
        hasCompletedSettingsOnboarding = UserDefaults.standard.bool(forKey: hasSeenSettingsOnboardingKey)
    }
    
    func startOnboarding() {
        guard !hasCompletedSettingsOnboarding else { return }
        currentTipIndex = 0
        showTips = true
    }
    
    func nextTip() {
        if currentTipIndex < tips.count - 1 {
            currentTipIndex += 1
        }
    }
    
    func finishOnboarding() {
        showTips = false
        currentTipIndex = 0
        saveOnboardingCompletion()
    }
    
    private func saveOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: hasSeenSettingsOnboardingKey)
        hasCompletedSettingsOnboarding = true
    }
    
    // MARK: - Debug/Testing Functions
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: hasSeenSettingsOnboardingKey)
        hasCompletedSettingsOnboarding = false
        currentTipIndex = 0
        showTips = false
    }
}

// MARK: - Settings Tip Overlay View
struct SettingsTipOverlay: View {
    @ObservedObject var tipManager: SettingsTipManager
    
    var body: some View {
        if tipManager.showTips, let tip = tipManager.currentTip {
            ZStack {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .blur(radius: 1.5)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(tip.message)
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                Button {
                                    handleSkipAction()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.system(size: 16))
                                }
                            }
                            
                            HStack {
                                if !tip.isLast {
                                    Button {
                                        handleSkipAction()
                                    } label: {
                                        Text("Skip")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 7)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    handleContinueAction()
                                } label: {
                                    Text(tip.isLast ? "Got it!" : "Next")
                                        .font(.custom("Poppins-Medium", size: 12))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 7)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white)
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 16,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 16
                            )
                            .fill(Color("Background"))
                        )
                        
                        HStack {
                            HStack(spacing: 8) {
                                Text(tip.title)
                                    .font(.custom("Poppins-Medium", size: 14))
                                
                                Spacer()
                                
                                Text("\(tip.id)/\(tipManager.tips.count)")
                                    .font(.custom("Poppins-Regular", size: 14))
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 16,
                                    bottomTrailingRadius: 16,
                                    topTrailingRadius: 0
                                )
                                .fill(Color.white)
                            )
                            .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: tipManager.showTips)
        }
    }
    
    private func handleSkipAction() {
        withAnimation {
            tipManager.finishOnboarding()
        }
    }
    
    private func handleContinueAction() {
        withAnimation {
            if tipManager.currentTip?.isLast == true {
                tipManager.finishOnboarding()
            } else {
                tipManager.nextTip()
            }
        }
    }
}
