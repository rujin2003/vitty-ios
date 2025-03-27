//
//  Reminder.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/9/25.
//
import SwiftUI
struct ReminderView: View {
    var courseName: String
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var url: String = ""
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var isAllDay = false
    @State private var startTime = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                      
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                if !showDatePicker {
                  
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Set New Reminder")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                       
                        TextField("Title", text: $title)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                        
                        TextField("Description", text: $description)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                       
                        HStack {
                            Text("Subject")
                                .foregroundColor(.white)
                                .frame(width: 80, alignment: .leading)
                            
                            HStack {
                                Text("Software Engineering")
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color("Secondary"))
                                    .cornerRadius(20)
                                
                                Text("ETH")
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color("Secondary"))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 10)
                        
                      
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text("Alert")
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text("None")
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                        
                       
                        Button(action: {}) {
                            Text("Add attachment...")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color("Secondary"))
                                .cornerRadius(10)
                        }
                        
                       
                        TextField("URL", text: $url)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    // Date Picker View
                    VStack(spacing: 20) {
                     
                        Text("February 2025")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                       
                        HStack(spacing: 0) {
                            ForEach(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], id: \.self) { day in
                                Text(day)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Calendar grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                            // Previous month days
                            ForEach(26...31, id: \.self) { day in
                                Text("\(day)")
                                    .frame(height: 40)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            
                            // Current month days
                            ForEach(1...28, id: \.self) { day in
                                if day == 23 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 40, height: 40)
                                        Text("\(day)")
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Text("\(day)")
                                        .frame(height: 40)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Next month day
                            Text("1")
                                .frame(height: 40)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(.horizontal)
                        
                      
                        HStack {
                            Text("All-day")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isAllDay)
                                .labelsHidden()
                        }
                        .padding(.horizontal)
                        
                      
                        if !isAllDay {
                            HStack {
                                Text("To")
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text("6:00AM")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            HStack {
                                Text("From")
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text("7:00AM")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
