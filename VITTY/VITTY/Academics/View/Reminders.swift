//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import SwiftUI

struct RemindersView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    @State private var reminders: [ReminderGroup] = [
        ReminderGroup(
            date: "27th February",
            daysToGo: 2,
            items: [
                ReminderItem(
                    title: "Digital Assignment I",
                    course: "Software Engineering - ETH",
                    isQuiz: false,
                    time: nil,
                    isCompleted: false
                ),
                ReminderItem(
                    title: "Quiz 1",
                    course: "Java Programming - ELA",
                    isQuiz: true,
                    time: "8 AM - 9 AM",
                    isCompleted: false
                )
            ]
        ),
        ReminderGroup(
            date: "1st March",
            daysToGo: 5,
            items: [
                ReminderItem(
                    title: "Digital Assignment I",
                    course: "Data Structures - CSE",
                    isQuiz: false,
                    time: nil,
                    isCompleted: false
                )
            ]
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color("Secondary"))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 16)
                
                HStack(spacing: 16) {
                    StatusTabView(isSelected: selectedTab == 0, title: "Pending")
                        .onTapGesture { selectedTab = 0 }
                    StatusTabView(isSelected: selectedTab == 1, title: "Completed")
                        .onTapGesture { selectedTab = 1 }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                VStack(spacing: 24) {
                    ForEach(Array(reminders.enumerated()), id: \.element.id) { groupIndex, group in
                        if selectedTab == 0 && !group.items.filter({ !$0.isCompleted }).isEmpty {
                            ReminderGroupView(
                                group: ReminderGroup(
                                    date: group.date,
                                    daysToGo: group.daysToGo,
                                    items: group.items.filter { !$0.isCompleted }
                                ),
                                completeItem: { itemId in
                                    completeReminderItem(groupIndex: groupIndex, itemId: itemId)
                                }
                            )
                            .transition(.move(edge: .trailing))
                        } else if selectedTab == 1 && !group.items.filter({ $0.isCompleted }).isEmpty {
                            ReminderGroupView(
                                group: ReminderGroup(
                                    date: group.date,
                                    daysToGo: group.daysToGo,
                                    items: group.items.filter { $0.isCompleted }
                                ),
                                completeItem: { _ in }
                            )
                            .transition(.move(edge: .trailing))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").edgesIgnoringSafeArea(.all))
    }
    
    private func completeReminderItem(groupIndex: Int, itemId: UUID) {
        if let itemIndex = reminders[groupIndex].items.firstIndex(where: { $0.id == itemId }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                reminders[groupIndex].items[itemIndex].isCompleted = true
            }
        }
    }
}

struct StatusTabView: View {
    let isSelected: Bool
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(isSelected ? Color("Accent") : Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ReminderGroupView: View {
    let group: ReminderGroup
    let completeItem: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.date)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(group.daysToGo <= 2 ? Color.red : Color.yellow)
                        .frame(width: 8, height: 8)
                    
                    Text("\(group.daysToGo) days to go")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(group.items) { item in
                    if item.isCompleted {
                       
                        ReminderItemView(item: item)
                    } else {
                      
                        SwipeableReminderItemView(
                            item: item,
                            onComplete: { completeItem(item.id) }
                        )
                    }
                }
            }
        }
    }
}


struct SwipeableReminderItemView: View {
    let item: ReminderItem
    let onComplete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isRemoved = false
    
    var body: some View {
        ZStack {
            if !isRemoved {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Completed")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100)
                    .frame(maxHeight: .infinity)
                    .background(Color.green)
                    .cornerRadius(16)
                    .opacity(offset < -75 ? 1 : 0)
                }
            }

            ReminderItemView(item: item)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !isRemoved {
                                offset = min(0, gesture.translation.width)
                            }
                        }
                        .onEnded { _ in
                            if offset < -75 {
                              
                               
                                    offset = -UIScreen.main.bounds.width
                                    isRemoved = true
                                
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onComplete()
                                }
                            } else {
                               
                                    offset = 0
                                
                            }
                        }
                )
        }
       
        .frame(height: isRemoved ? 0 : 80)
        .opacity(isRemoved ? 0 : 1)
        
    }
}

struct ReminderItemView: View {
    let item: ReminderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title + " | " + (item.time ?? ""))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            HStack {
                Text(item.course)
                    .font(.system(size: 14))
                    .foregroundColor(Color("Accent"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
    }
}

struct ReminderGroup: Identifiable {
    let id = UUID()
    let date: String
    let daysToGo: Int
    var items: [ReminderItem]
}

struct ReminderItem: Identifiable {
    let id = UUID()
    let title: String
    let course: String
    let isQuiz: Bool
    let time: String?
    var isCompleted: Bool
}
