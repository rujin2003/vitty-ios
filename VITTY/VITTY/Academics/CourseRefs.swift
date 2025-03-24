import SwiftUI

struct CourseRefs: View {
    var courseName: String
    var courseInstitution: String
    @State private var showBottomSheet = false
    @State private var showReminderSheet = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
               
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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

                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding()

                
                HStack{
                    Spacer()
                    TextField("Search", text: .constant(""))
                        .padding(10)
                        .frame(width: UIScreen.main.bounds.width * 0.85)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer().frame(height: 10)

                
                Text("\(courseName) - \(courseInstitution)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal)

               
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TagView(title: "DA I by 24 May", color: .red)
                        TagView(title: "DA II by 2 June", color: .yellow)
                        TagView(title: "Quiz I on 2 Jan", color: .green)
                        TagView(title: "+3", color: .yellow)

                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

               
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        CourseCardNotes(title: "Sample Title", description: "Data science and software engineering experience is recommended.")
                            
                        CourseCardNotes(title: "More Information", description: "This certification is intended for you if you have both technical and non-technical backgrounds.")
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
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showBottomSheet) {
            ZStack {
                Color("Secondary").edgesIgnoringSafeArea(.all)
                
                HStack {
                    BottomSheetButton(icon: "upload", title: "Write Note")
                    BottomSheetButton(icon: "edit_document", title: "Upload File")
                    BottomSheetButton(icon: "alarm", title: "Set Reminder") {
                        showBottomSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showReminderSheet = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReminderSheet) {
            ReminderView(courseName: courseName)
               
        }
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
    var title: String
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct CourseCardNotes: View {
    var title: String
    var description: String
  
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
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

