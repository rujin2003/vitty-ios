//
//  InstructionsView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct InstructionsView: View {
    @EnvironmentObject var authState: AuthService
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
                }
            }
            .padding()
        .background(Image("InstructionsBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
            
            if displayLogout {
                LogoutPopup(showLogout: $displayLogout)
            }
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
