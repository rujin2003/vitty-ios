//
//  ClassCards.swift
//  VITTY
//
//  Created by Ananya George on 12/24/21.
//

import SwiftUI

struct ClassCards: View {
    var classInfo: Classes
    @State var currentClass: Bool =  false
    @State var hideDescription: Bool = true
    @State var onlineMode: Bool
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack(alignment:.leading) {
                        Text(classInfo.courseName ?? "Course Name")
                            .font(Font.custom("Poppins-SemiBold",size:15))
                            .foregroundColor(Color.white)
                        HStack(spacing: 0) {
                            Text(classInfo.startTime ?? Date(), style: .time)
                            Text(" - ")
                            Text(classInfo.endTime ?? Date(), style: .time)
                        }
                            .font(Font.custom("Poppins-Regular",size:14))
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
                        Text("\(classInfo.slot ?? "Slot")")
                            .font(Font.custom("Poppins-Regular",size:14))
                        Spacer()
//                        TODO: remote config
                        if onlineMode {
                        Text("\(classInfo.location ?? "Location")")
                            .font(Font.custom("Poppins-Regular",size:14))
                        } else {
                            HStack {
                                Text("\(classInfo.location ?? "Location")")
                                    .font(Font.custom("Poppins-Regular",size:14))
                                Image(systemName: "mappin.and.ellipse")
                            }
                            .padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: 1).foregroundColor(Color.vprimary))
                            .onTapGesture {
                                ClassCardViewModel.classCardVM.navigateToClass(at: classInfo.location ?? "SJT")
                            }
                        }
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
        ClassCards(classInfo: StringConstants.sampleClassDate, onlineMode: false)
    }
}
