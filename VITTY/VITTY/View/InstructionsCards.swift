//
//  InstructionsCards.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct InstructionsCards: View {
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .fill(Color.darkbg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.vprimary, lineWidth: 1.2)
                    )
                VStack(alignment: .leading) {
                    Text(StringConstants.instructionsHeaders[0])
                        .font(Font.custom("Poppins-SemiBold",size: 20))
                        .foregroundColor(Color.white)
                        .padding(.vertical,5)
                    ForEach(StringConstants.accDetails, id: \.self) { point in
                        Text(point)
                            .foregroundColor(Color.vprimary)
                    }
                }
                .padding()
                .font(Font.custom("Poppins-Regular",size:16))
            }
            .frame(height: 100)
            .padding(.vertical)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .fill(Color.darkbg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.vprimary, lineWidth: 1.2)
                    )
                VStack(alignment: .leading) {
                    Text(StringConstants.instructionsHeaders[1])
                        .font(Font.custom("Poppins-SemiBold",size: 20))
                        .foregroundColor(Color.white)
                        .padding(.vertical,5)
                    ScrollView {
                        VStack(alignment:.leading) {
                            ForEach(StringConstants.setupInstructions, id: \.self) { point in
                                Text(point)
                                    .foregroundColor(Color.vprimary)
                            }
                            Text(StringConstants.setupFinalText)
                                .foregroundColor(Color.white)
                                .padding(.vertical)
                        }
                    }
                    
                }
                .padding()
                .font(Font.custom("Poppins-Regular",size:16))
            }
            .frame(height: 300)
            .padding(.vertical)
        }
    }
}

struct InstructionsCards_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsCards()
    }
}
