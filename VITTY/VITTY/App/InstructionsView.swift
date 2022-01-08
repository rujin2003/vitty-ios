//
//  InstructionsView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct InstructionsView: View {
    @EnvironmentObject var authState: AuthService
    @EnvironmentObject var ttVM: TimetableViewModel
    @State var goToHomeScreen = UserDefaults.standard.bool(forKey: "instructionsComplete")
    @State var displayLogout: Bool = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Sync Timetable")
                    Spacer()
                    // add logout button functionality
                    Image(systemName: "arrow.right.square")
                        .onTapGesture {
                           displayLogout = true
                        }
                }
                .font(Font.custom("Poppins-Bold", size: 24))
                .foregroundColor(Color.white)
                ScrollView {
                    InstructionsCards()
                        .padding(.vertical)
                }
                Spacer()
                CustomButton(buttonText: "Done") {
                    if ttVM.timetable.isEmpty {
                        ttVM.getData()
                    } else {
                        print("time table is populated")
                        UserDefaults.standard.set(true, forKey:"instructionsComplete")
                        goToHomeScreen = true
                    }
                }
                NavigationLink(destination: HomePage().navigationTitle("").navigationBarHidden(true).environmentObject(ttVM).environmentObject(authState), isActive: $goToHomeScreen) {
                    EmptyView()
                }
            }
            .padding()
        .background(Image("InstructionsBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
            
            if displayLogout {
                LogoutPopup(showLogout: $displayLogout)
            }
        }
        .onAppear {
            ttVM.getData()
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
