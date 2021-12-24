//
//  InstructionsView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Sync Timetable")
                Spacer()
                // add logout button functionality
                Image(systemName: "arrow.right.square")
            }
            .font(Font.custom("Poppins-Bold", size: 24))
            .foregroundColor(Color.white)
            InstructionsCards()
            Spacer()
            CustomButton(buttonText: "Done") {
            }
        }
        .padding()
        .background(Image("InstructionsBG").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
