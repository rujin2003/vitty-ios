//
//  SplashScreen.swift
//  VITTY
//
//  Created by Ananya George on 12/22/21.
//

import SwiftUI

struct SplashScreen: View {
    @State var selectedTab: Int = 0
    @State var onboardingComplete: Bool = false
    var body: some View {
        VStack {
            TabView(selection: $selectedTab){
                ForEach(0..<3) { _ in
                    SplashScreenIllustration(selectedTab: $selectedTab)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            SplashScreenTabIndicator(selectedTab: $selectedTab)
            Spacer(minLength: 50)
            if selectedTab < 2 {
                CustomButton(buttonText:"Next") {
                    selectedTab += 1
                }
                .padding(.vertical)
                
            } else {
                NavigationLink(destination: HomePage().navigationBarHidden(true), isActive: $onboardingComplete) {
                    CustomButton(buttonText: "Sign in with google"){
                        onboardingComplete = true
                    }
                }
                SignupOR()
                CustomButton(buttonText:"Sign in with apple"){}
            }
            Spacer(minLength: 50)
            
        }
        .animation(.linear(duration: 0.25))
        .padding()
        .background(Image((selectedTab % 2 == 0) ? "SplashScreen13BG" : "SplashScreen2BG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
