//
//  TimeTableScrollView.swift
//  VITTY
//
//  Created by Ananya George on 1/21/22.
//

import SwiftUI

struct TimeTableScrollView: View {
    var selectedTT: [Classes]
    @Binding var tabSelected: Int
    @EnvironmentObject var timetableViewModel: TimetableViewModel
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                ForEach(0..<selectedTT.count, id:\.self) { ind in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.darkbg)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.secGrad)
                            .opacity((tabSelected == (Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1) && timetableViewModel.classesCompleted == ind ? 1 : 0)
                        ClassCards(classInfo: selectedTT[ind])
                            .id(ind)
                    }
                    .padding(.bottom,5)
                }
                .onAppear {
                    print((Calendar.current.dateComponents([.weekday], from: Date()).weekday ?? 1) - 1)
                    print(tabSelected)
                    scrollView.scrollTo(timetableViewModel.classesCompleted)
                    
                    
                }
            }
            .padding(.top, 5)
            .padding(.horizontal, 10)
            .onAppear {
                timetableViewModel.updateClassCompleted()
            }
        }
    }
}

