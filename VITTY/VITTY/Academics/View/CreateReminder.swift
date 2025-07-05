//
//  CreateGroup.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI
import SwiftData

struct ReminderView: View {
    var courseName: String
    var slot: String
    var courseCode: String

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
               
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Add") {
                        let newReminder = Remainder(
                            title: title,
                            subject: courseName,
                            slot: slot,
                            courseCode: courseCode,
                            date: selectedDate,
                            isCompleted: false,
                            subjectDescription: description,
                            startTime: startTime,
                            endTime: endTime
                        )

                        do {
                            modelContext.insert(newReminder)
                            try modelContext.save()
                            print("Saved successfully")

                          
                            NotificationManager.shared.scheduleReminderNotifications(
                                title: title,
                                date: startTime,
                                subject: courseName
                            )

                        } catch {
                            print("Failed to save: \(error.localizedDescription)")
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!isFormValid)
                    .foregroundColor(isFormValid ? .red : .gray)
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Set New Reminder")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom)

                        TextField("Title", text: $title)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)

                        TextField("Description (Optional)", text: $description)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)

                        HStack {
                            Text("Subject")
                                .foregroundColor(.white)
                            Spacer()
                            Text(courseName)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("Secondary"))
                                .cornerRadius(20)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Alert Date")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(selectedDate, style: .date)
                                    .foregroundColor(.gray)
                                Image(systemName: showDatePicker ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                                    .rotationEffect(.degrees(showDatePicker ? 0 : 0))
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                   
                                    showStartTimePicker = false
                                    showEndTimePicker = false
                                    showDatePicker.toggle()
                                }
                            }

                            if showDatePicker {
                                DatePicker(
                                    "Select Date",
                                    selection: $selectedDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .colorScheme(.dark)
                                .labelsHidden()
                                .onChange(of: selectedDate) {
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showDatePicker = false
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }

                       
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Start Time")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(startTime, style: .time)
                                    .foregroundColor(.gray)
                                Image(systemName: showStartTimePicker ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                 
                                    showDatePicker = false
                                    showEndTimePicker = false
                                    showStartTimePicker.toggle()
                                }
                            }

                            if showStartTimePicker {
                                VStack(spacing: 12) {
                                    DatePicker(
                                        "Start Time",
                                        selection: $startTime,
                                        displayedComponents: [.hourAndMinute]
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(height: 120)
                                    .clipped()

                                    Button("Done") {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showStartTimePicker = false
                                        }
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }

                     
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("End Time")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(endTime, style: .time)
                                    .foregroundColor(.gray)
                                Image(systemName: showEndTimePicker ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                   
                                    showDatePicker = false
                                    showStartTimePicker = false
                                    showEndTimePicker.toggle()
                                }
                            }

                            if showEndTimePicker {
                                VStack(spacing: 12) {
                                    DatePicker(
                                        "End Time",
                                        selection: $endTime,
                                        displayedComponents: [.hourAndMinute]
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .frame(height: 120)
                                    .clipped()

                                    Button("Done") {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showEndTimePicker = false
                                        }
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onTapGesture {
       
            withAnimation(.easeInOut(duration: 0.3)) {
                showDatePicker = false
                showStartTimePicker = false
                showEndTimePicker = false
            }
        }
    }
}
