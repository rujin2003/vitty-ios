//
//  HomeTabBarView.swift
//  VITTY
//
//  Created by Ananya George on 12/23/21.
//

import SwiftUI

struct HomeTabBarView: View {
    @Binding var tabSelected: Int
    var body: some View {
        HStack(spacing:0) {
            ForEach(0..<StringConstants.daysOfTheWeek.count) { i in
                ZStack {
                    if tabSelected == i {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.secGrad)
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            tabSelected = i
                        }, label: {
                            Text(StringConstants.daysOfTheWeek[i])
                                .font(Font.custom("Poppins-Medium", size: 15))
                                .foregroundColor(tabSelected==i ? Color.white : Color.vprimary)
                        })
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal,5)
        .frame(height: 50)
        .background(Color.darkbg)
    }
}

struct HomeTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabBarView(tabSelected: .constant(1))
    }
}
