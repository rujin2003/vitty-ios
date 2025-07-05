//
//  ToolTip.swift
//  VITTY
//
//  Created by Rujin Devkota on 7/1/25.
//

// MARK: - Tips Definition
import SwiftUI

struct CustomTip {
    let id: Int
    let title: String
    let message: String
    let targetTab: Int
    let isLast: Bool
}

// MARK: - Custom Tip Manager
class CustomTipManager: ObservableObject {
    @Published var currentTipIndex = 0
    @Published var showTips = false
    @Published var hasCompletedOnboarding = false
    
    private var hasSeenOnboardingKey: String { "hasSeenOnboarding" }
    
    let tips: [CustomTip] = [
        CustomTip(
            id: 1,
            title: "Navigation Bar",
            message: "This is your main dashboard, where you can access everything in one place — your courses and reminders in Academics, your timetable in Schedule, and your friends, groups, and rooms in Connect.",
            targetTab: 1,
            isLast: false
        ),
        CustomTip(
            id: 2,
            title: "Academics — Track Your Coursework",
            message: "Academics keeps you organized with your courses and shows reminders for upcoming assignments, quizzes, and deadlines.",
            targetTab: 3,
            isLast: false
        ),
        CustomTip(
            id: 3,
            title: "Schedule — View Your Timetable",
            message: "Schedule gives you a clear view of your classes, helping you plan your day or week with ease.",
            targetTab: 1,
            isLast: false
        ),
        CustomTip(
            id: 4,
            title: "Connect — Collaborate with Peers",
            message: "Connect lets you see friends, manage groups, and join or create rooms to collaborate and stay connected.",
            targetTab: 2,
            isLast: true
        )
    ]
    
    init() {
        checkOnboardingStatus()
    }
    
    var currentTip: CustomTip? {
        guard currentTipIndex < tips.count else { return nil }
        return tips[currentTipIndex]
    }
    
    func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }
    
    func startOnboarding() {
        guard !hasCompletedOnboarding else { return }
        currentTipIndex = 0
        showTips = true
    }
    
    func nextTip() -> Int? {
        if currentTipIndex < tips.count - 1 {
            currentTipIndex += 1
            return tips[currentTipIndex].targetTab
        }
        return nil
    }
    
    func finishOnboarding() {
        showTips = false
        currentTipIndex = 0
        saveOnboardingCompletion()
    }
    
    private func saveOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
        hasCompletedOnboarding = true
    }
    
    // MARK: - Debug/Testing Functions
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: hasSeenOnboardingKey)
        hasCompletedOnboarding = false
        currentTipIndex = 0
        showTips = false
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var effect: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: effect))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: effect)
    }
}

// MARK: - Custom Tip Overlay View
struct CustomTipOverlay: View {
    @ObservedObject var tipManager: CustomTipManager
    @Binding var selectedTab: Int
    
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
                                    handleTipAction()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.system(size: 16))
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Button {
                                    handleContinueAction()
                                } label: {
                                    Text(tip.isLast ? "Finish" : "Continue")
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
    
    private func handleTipAction() {
        withAnimation {
            tipManager.finishOnboarding()
        }
    }
    
    private func handleContinueAction() {
        withAnimation {
            if tipManager.currentTip?.isLast == true {
                tipManager.finishOnboarding()
            } else {
                if let nextTab = tipManager.nextTip() {
                    selectedTab = nextTab
                }
            }
        }
    }
}
