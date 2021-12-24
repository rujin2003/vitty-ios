//
//  ClassCards.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct ClassCards: View {
    @State var currentClass: Bool =  true
    @State var hideDescription: Bool = true
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkbg)
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient.secGrad)
                .opacity(currentClass ? 1 : 0)
            VStack {
                HStack {
                    VStack(alignment:.leading) {
                        Text("Class Name")
                            .font(Font.custom("Poppins-SemiBold",size:16))
                            .foregroundColor(Color.white)
                        Text("Time")
                            .font(Font.custom("Poppins-Regular",size:15))
                    }
                    .padding()
                    Spacer()
                    Image(systemName: hideDescription ? "chevron.down" : "chevron.up")
                        .font(Font.system(size: 18))
                        .padding()
                        .onTapGesture {
                            hideDescription.toggle()
                        }
                }
                if !hideDescription {
                    HStack {
                        Text("Slot")
                            .font(Font.custom("Poppins-Regular",size:15))
                        Spacer()
                        Button(action: {
                        }
                               , label: {
                            HStack(spacing:3) {
                                Text("Room No")
                                    .padding(.leading,3)
                                Image(systemName: "arrow.up.right.diamond.fill")
                            }
                            .font(Font.custom("Poppins-Regular",size:15))
                                .cornerRadius(20)
                                .padding(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.vprimary, lineWidth: 1.2)
                            )
                        }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .foregroundColor(Color.vprimary)
            .padding()
        }
        .padding()
        .frame(height: hideDescription ? 100 : 155)
    }
}

struct ClassCards_Previews: PreviewProvider {
    static var previews: some View {
        ClassCards()
    }
}
