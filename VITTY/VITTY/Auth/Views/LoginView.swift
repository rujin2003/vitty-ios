//
//  LoginView.swift
//  VITTY
//
//  Created by Chandram Dutta on 04/02/24.
//

import OSLog
import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var animationProgress = 0.0
    @State private var scrollPosition: Int? = 0  // Changed to optional Int
    
    private let carouselItems = [
        LoginViewCarouselItem(image: "LoginViewIllustration 2", heading: "Never miss a class", subtitle: "Notifications to remind you about your upcoming classes"),
        LoginViewCarouselItem(image: "LoginViewIllustration 1", heading: "Get a sneak peek", subtitle: "View your upcoming classes and timetable via the widget"),
        LoginViewCarouselItem(image: "LoginViewIllustration 3", heading: "Upload Once, view everywhere", subtitle: "Instant Sync across all of your devices via the app")
    ]

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollViewReader { value in
                VStack(alignment: .center) {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(carouselItems.indices, id: \.self) { index in
                                CarouselItemView(item: carouselItems[index], index: index, lastIndex: carouselItems.count - 1)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollPosition)  // Use scrollPosition instead of currentPage
                    .onChange(of: scrollPosition) { _, newValue in
                        print("Current page changed to: \(newValue ?? 0)")
                    }
                    .offset(x: -animationProgress * 75)
                    .animation(.spring(), value: animationProgress)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.linear(duration: 1.0)) {
                                animationProgress = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                withAnimation(.linear(duration: 2.0)) {
                                    animationProgress = 0.0
                                }
                            }
                        }
                    }
                    
                    
                    PageIndicatorView(currentPage: scrollPosition ?? 0, totalPages: carouselItems.count)  // Use scrollPosition
                        .padding(.top, 20)
                }
                .safeAreaPadding()
            }
        }
    }
}

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color("Accent") : Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
    }
}

struct SignInButtonsView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack {
            Button(action: {
                Task {
                    authViewModel.isLoadingApple = true
                    await authViewModel.login(with: .appleSignIn)
                    authViewModel.isLoadingApple = false
                }
            }) {
                HStack {
                    if authViewModel.isLoadingApple {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    } else {
                        Image("logo_apple")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Sign In With Apple")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color("Secondary"))
            .cornerRadius(18)
            .padding([.top, .leading, .trailing])

            Button(action: {
                Task {
                    authViewModel.isLoadingGoogle = true
                    await authViewModel.login(with: .googleSignIn)
                    authViewModel.isLoadingGoogle = false
                }
            }) {
                HStack {
                    if authViewModel.isLoadingGoogle {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    } else {
                        Image("logo_google")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Sign In With Google")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color("Secondary"))
            .cornerRadius(18)
            .padding()
        }
    }
}

struct LoginViewCarouselItem {
    let image: String
    let heading: String
    let subtitle: String
}

extension Comparable {
    func clamped(to range: Range<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

struct CarouselItemView: View {
    let item: LoginViewCarouselItem
    let index: Int
    let lastIndex: Int
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack {
            if index == lastIndex {
                Spacer()
            }
            Image(item.image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 64)
                .frame(height: 400)
            Text(item.heading)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
            Text(item.subtitle)
                .font(.footnote)
                .foregroundColor(Color("Accent"))
                .multilineTextAlignment(.center)
                .frame(width: 400)
                .padding(.top, 1)
            if index == lastIndex {
                Spacer()
                SignInButtonsView()
            }
        }
        .containerRelativeFrame(.horizontal)
        .scrollTransition(.animated, axis: .horizontal) { content, phase in
            content
                .opacity(phase.isIdentity ? 1.0 : 0.8)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
        }
    }
}
