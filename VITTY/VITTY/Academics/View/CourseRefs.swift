//
//  Academics.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.

import SwiftUI
import SwiftData

struct OCourseRefs: View {
    var courseName: String
    var courseInstitution: String
    var slot: String
    var courseCode: String

    @State private var showBottomSheet = false
    @State private var showReminderSheet = false
    @State private var showNotes = false
    @State private var navigateToNotesEditor = false
    @State var showCourseNotes: Bool = false
    @State private var selectedNote: CreateNoteModel?
    @State private var preloadedAttributedString: NSAttributedString?
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var noteToDelete: CreateNoteModel?
    @State private var isLoadingNote = false
    @State private var loadingNoteId: Date?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
  
    private let maxVisible = 4

    @Query private var filteredRemainders: [Remainder]
    @Query private var courseNotes: [CreateNoteModel]

    init(courseName: String, courseInstitution: String, slot: String, courseCode: String) {
        self.courseName = courseName
        self.courseInstitution = courseInstitution
        self.slot = slot
        self.courseCode = courseCode

        let reminderPredicate = #Predicate<Remainder> {
            $0.subject == courseName && $0.isCompleted == false
        }
        _filteredRemainders = Query(
            FetchDescriptor(predicate: reminderPredicate, sortBy: [SortDescriptor(\.date, order: .forward)])
        )

        let notesPredicate = #Predicate<CreateNoteModel> {
            $0.courseId == courseCode
        }
        _courseNotes = Query(
            FetchDescriptor(predicate: notesPredicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        )
    }

    private var filteredNotes: [CreateNoteModel] {
        if searchText.isEmpty {
            return courseNotes
        } else {
            return courseNotes.filter { note in
                note.noteName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Background").edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text("Course Page")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()

                    HStack {
                        Spacer()
                        TextField("Search notes...", text: $searchText)
                            .padding(10)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer().frame(height: 20)

                    Text("\(courseName) - \(courseInstitution)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            let visible = Array(filteredRemainders.prefix(maxVisible))
                            ForEach(visible, id: \.self) { reminder in
                                TagView(reminder: reminder)
                            }

                            let remainingCount = filteredRemainders.count - maxVisible
                            if remainingCount > 0 {
                                MoreTagView(count: remainingCount)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15) {
                            if filteredNotes.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: searchText.isEmpty ? "doc.text" : "magnifyingglass")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray.opacity(0.6))
                                    
                                    Text(searchText.isEmpty ? "No notes found for this course" : "No notes match your search")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.center)
                                    
                                    if !searchText.isEmpty {
                                        Text("Try searching with different keywords")
                                            .foregroundColor(.gray.opacity(0.8))
                                            .font(.system(size: 14))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            } else {
                                ForEach(filteredNotes, id: \.createdAt) { note in
                                    CourseCardNotes(
                                        title: note.noteName,
                                        description: note.cachedPlainText,
                                        isLoading: loadingNoteId == note.createdAt,
                                        onDelete: {
                                            noteToDelete = note
                                            showDeleteAlert = true
                                        }
                                    )
                                    .onTapGesture {
                                        openNote(note)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showBottomSheet.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .padding(18)
                                .background(Color("Secondary"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }

               
                if showDeleteAlert {
                    DeleteNoteAlert(
                        noteName: noteToDelete?.noteName ?? "",
                        onCancel: {
                            showDeleteAlert = false
                            noteToDelete = nil
                        },
                        onDelete: {
                            deleteNote()
                        }
                    )
                    .zIndex(1)
                }
            }
            .onAppear {
                print("this is course code")
                print(courseCode)
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showBottomSheet) {
                ZStack {
                    Color("Secondary").edgesIgnoringSafeArea(.all)

                    HStack {
                        BottomSheetButton(icon: "upload", title: "Write Note") {
                            showBottomSheet = false
                            navigateToNotesEditor = true
                        }

                        BottomSheetButton(icon: "edit_document", title: "Upload File")
                        BottomSheetButton(icon: "alarm", title: "Set Reminder") {
                            showBottomSheet = false
                            showReminderSheet = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showReminderSheet) {
                ReminderView(courseName: courseName, slot: slot, courseCode: courseCode)
                    .presentationDetents([.fraction(0.8)])
            }
           
            .navigationDestination(isPresented: $navigateToNotesEditor) {
                NoteEditorView(courseCode: courseCode, courseName: courseName, courseIns: courseInstitution, courseSlot: slot)
            }
            .sheet(isPresented: $showNotes, content: {
                NoteEditorView(
                    existingNote: selectedNote,
                    preloadedAttributedString: preloadedAttributedString,
                    courseCode: courseCode,
                    courseName: courseName,
                    courseIns: courseInstitution,
                    courseSlot: slot
                )
            })
        }
    }

    // MARK: - Note Loading Function
    private func openNote(_ note: CreateNoteModel) {
        guard !isLoadingNote else { return }
        
       
        isLoadingNote = true
        loadingNoteId = note.createdAt
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        Task { @MainActor in
            do {
                let attributedString = try await loadNoteContent(note)
                
               
                selectedNote = note
                preloadedAttributedString = attributedString
                
             
                try await Task.sleep(nanoseconds: 300_000_000)
                
            
                isLoadingNote = false
                loadingNoteId = nil
                showNotes = true
                
            } catch {
                print("Error loading note: \(error)")
                isLoadingNote = false
                loadingNoteId = nil
                
               
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
    
    @MainActor
    private func loadNoteContent(_ note: CreateNoteModel) async throws -> NSAttributedString {
       
        if let cachedAttributedString = note.cachedAttributedString {
            return cachedAttributedString
        }
        
     
        guard let data = Data(base64Encoded: note.noteContent) else {
            throw NoteLoadingError.invalidData
        }
        
      
        if let attributedString = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
            return attributedString
        } else {
            throw NoteLoadingError.unarchiveFailed
        }
    }

    private func deleteNote() {
        guard let note = noteToDelete else { return }
        
      
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
       
        modelContext.delete(note)
        
       
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete note: \(error)")
        }
       
        showDeleteAlert = false
        noteToDelete = nil
    }
}

// MARK: - Error Handling
enum NoteLoadingError: Error {
    case invalidData
    case unarchiveFailed
}

struct DeleteNoteAlert: View {
    let noteName: String
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Delete note?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to delete '\(noteName)'?")
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
                    
                    Button(action: onDelete) {
                        Text("Delete")
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
    }
}

struct BottomSheetButton: View {
    var icon: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack {
                Image(icon)
                    .font(.title)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
        }
    }
}

struct TagView: View {
    var reminder: Remainder

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(tagColor)

            Text(reminder.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
    }

    private var tagColor: Color {
        let now = Date()
        let calendar = Calendar.current
        if let daysBetween = calendar.dateComponents([.day], from: now, to: reminder.date).day,
           daysBetween >= 0 && daysBetween <= 7 {
            return .red
        } else {
            return .green
        }
    }
}

struct MoreTagView: View {
    var count: Int

    var body: some View {
        Text("+\(count) more")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
    }
}


struct CourseCardNotes: View {
    var title: String
    var description: String
    var isLoading: Bool = false
    var onDelete: () -> Void

    @State private var showComingSoonAlert = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            if isLoading {
               
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                    .padding(.trailing, 8)
            } else {
                Menu {
                    Button(role: .destructive) {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        showComingSoonAlert = true
                    } label: {
                        Label("Export Markdown", systemImage: "square.and.arrow.down")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .padding(8)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .opacity(isLoading ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .alert("Feature coming soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
