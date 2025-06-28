import SwiftUI
import SwiftData




struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var timeTables: [TimeTable]

    @StateObject private var viewModel = SettingsViewModel()

   
    @State private var showDaySelection = false
    @State private var selectedDay: String? = nil
    @State private var showResetAlert = false
    
 
    private let selectedDayKey = "SelectedSaturdayDay"

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack {
                    headerView

                    List {
                        SettingsSectionView(title: "Account Details") {
                            HStack(spacing: 12) {
                                UserImage(
                                    url: authViewModel.loggedInBackendUser?.picture ?? "",
                                    height: 60,
                                    width: 60
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(authViewModel.loggedInFirebaseUser?.displayName ?? "")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(authViewModel.loggedInFirebaseUser?.email ?? "")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                        }

                        SettingsSectionView(title: "Class Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                Button {
                                    showDaySelection.toggle()
                                } label: {
                                    SettingsRowView(
                                        icon: "calendar.badge.plus",
                                        title: "Saturday Class",
                                        subtitle: selectedDay == nil ? "Select a day to copy classes to Saturday" : "Copy \(selectedDay!) classes to Saturday"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showDaySelection {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                                            HStack(spacing: 12) {
                                                Image(systemName: selectedDay == day ? "largecircle.fill.circle" : "circle")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 16))
                                                Text(day)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14))
                                                Spacer()
                                            }
                                            .padding(.leading, 16)
                                            .padding(.vertical, 4)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selectedDay = day
                                                UserDefaults.standard.set(day, forKey: selectedDayKey)
                                                copyLecturesToSaturday(from: day)
                                                showDaySelection = false
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                                    ))
                                }
                                
                                
                                Button {
                                    showResetAlert = true
                                } label: {
                                    SettingsRowView(
                                        icon: "trash.circle.fill",
                                        title: "Reset Saturday Classes",
                                        subtitle: "Remove all classes from Saturday"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button {
                                    if let url = URL(string: "https://vitty.dscvit.com") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    SettingsRowView(
                                        icon: "pencil.and.ellipsis.rectangle",
                                        title: "Update Timetable",
                                        subtitle: "Keep your timetable up-to-date. Don't miss a class."
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        SettingsSectionView(title: "Notifications") {
                            Toggle(isOn: $viewModel.notificationsEnabled) {
                                HStack {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(.white)
                                    Text("Enable Notifications")
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .semibold))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        }

                        SettingsSectionView(title: "About") {
                            AboutLinkView(image: "github-icon", title: "GitHub Repository", url: URL(string: "https://github.com/GDGVIT/vitty-ios"))
                            AboutLinkView(image: "gdsc-logo", title: "GDSC VIT", url: URL(string: "https://dscvit.com/"))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                
                if showResetAlert {
                    ResetSaturdayAlert(
                        onCancel: {
                            showResetAlert = false
                        },
                        onReset: {
                            resetSaturdayClasses()
                            showResetAlert = false
                        }
                    )
                    .zIndex(1)
                }
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(true)
            .onAppear {
                viewModel.timetable = timeTables.first
                viewModel.checkNotificationAuthorization()
                loadSelectedDay()
                print("Saturday before save:", timeTables[0].saturday.map { $0.name })

            }
            .alert("Notifications Disabled", isPresented: $viewModel.showNotificationDisabledAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You will no longer receive class reminders.")
            }
        }
    }
    
 
    
    private func loadSelectedDay() {
        selectedDay = UserDefaults.standard.string(forKey: selectedDayKey)
    }
    
    private func resetSaturdayClasses() {
        guard let timeTable = timeTables.first else { return }
        
      
        let newTimeTable = TimeTable(
            monday: timeTable.monday,
            tuesday: timeTable.tuesday,
            wednesday: timeTable.wednesday,
            thursday: timeTable.thursday,
            friday: timeTable.friday,
            saturday: [], // Empty Saturday
            sunday: timeTable.sunday
        )
        
        
        modelContext.delete(timeTable)
        modelContext.insert(newTimeTable)
        
      
        do {
            try modelContext.save()
            print("Successfully reset Saturday classes")
            
            
            UserDefaults.standard.removeObject(forKey: selectedDayKey)
            selectedDay = nil
            
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func copyLecturesToSaturday(from day: String) {
        guard let timeTable = timeTables.first else { return }
        
        let lecturesToCopy: [Lecture]
        
        switch day {
        case "Monday":
            lecturesToCopy = timeTable.monday
        case "Tuesday":
            lecturesToCopy = timeTable.tuesday
        case "Wednesday":
            lecturesToCopy = timeTable.wednesday
        case "Thursday":
            lecturesToCopy = timeTable.thursday
        case "Friday":
            lecturesToCopy = timeTable.friday
        default:
            lecturesToCopy = []
        }
        
      
        let newTimeTable = TimeTable(
            monday: timeTable.monday,
            tuesday: timeTable.tuesday,
            wednesday: timeTable.wednesday,
            thursday: timeTable.thursday,
            friday: timeTable.friday,
            saturday: lecturesToCopy.map { lecture in
                Lecture(
                    name: lecture.name,
                    code: lecture.code,
                    venue: lecture.venue,
                    slot: lecture.slot,
                    type: lecture.type,
                    startTime: lecture.startTime,
                    endTime: lecture.endTime
                )
            },
            sunday: timeTable.sunday
        )
        
       
        modelContext.delete(timeTable)
        modelContext.insert(newTimeTable)
        
       
        do {
            try modelContext.save()
            print("Successfully replaced timetable with copied lectures from \(day) to Saturday")
        } catch {
            print("Error saving context: \(error)")
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            Spacer()
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }

    struct SettingsSectionView<Content: View>: View {
        let title: String
        @ViewBuilder let content: () -> Content

        var body: some View {
            Section(header: Text(title).foregroundColor(.white)) {
                content()
                    .padding(.vertical, 6)
            }
            .listRowBackground(Color("Secondary"))
        }
    }

    struct SettingsRowView: View {
        let icon: String
        let title: String
        let subtitle: String

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }

    struct AboutLinkView: View {
        let image: String
        let title: String
        let url: URL?

        var body: some View {
            HStack(spacing: 12) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 6)
            .onTapGesture {
                if let url = url {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// Custom Reset Alert Component
struct ResetSaturdayAlert: View {
    let onCancel: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Reset Saturday Classes?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to remove all classes from Saturday? This action cannot be undone.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onReset) {
                        Text("Reset")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        .onTapGesture {
           
        }
    }
}
