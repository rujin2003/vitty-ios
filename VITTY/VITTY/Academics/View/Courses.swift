import SwiftUI

struct CoursesView: View {
    @State private var searchText = ""
    @State private var isCurrentSemester = true
    
    @State private var courses: [Course] = [
        Course(
            title: "Software Engineering - ETH",
            code: "C2 + TC2",
            semester: "Winter 2023-24",
            isFavorite: true
        ),
        Course(
            title: "Java Programming - ELA",
            code: "C2 + TC2",
            semester: "Winter 2023-24",
            isFavorite: false
        ),
        Course(
            title: "Data Structures - CSE",
            code: "C2 + TC2",
            semester: "Winter 2023-24",
            isFavorite: false
        ),
        Course(
            title: "Computer Networks - ETH",
            code: "C2 + TC2",
            semester: "Winter 2023-24",
            isFavorite: false
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
               
                SearchBar(searchText: $searchText)
                
             
                HStack(spacing: 16) {
                    SemesterFilterButton(isSelected: isCurrentSemester, title: "Current Semester")
                        .onTapGesture { isCurrentSemester = true }
                    
                    SemesterFilterButton(isSelected: !isCurrentSemester, title: "All Semesters")
                        .onTapGesture { isCurrentSemester = false }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Course List
                VStack(spacing: 16) {
                    ForEach(filteredCourses) { course in
                        NavigationLink(destination: CourseRefs(courseName: course.title, courseInstitution: course.code)) {
                            CourseCardView(course: course)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").edgesIgnoringSafeArea(.all))
    }
    
    private var filteredCourses: [Course] {
        courses.filter { course in
            let matchesSearch = searchText.isEmpty ||
                course.title.lowercased().contains(searchText.lowercased())
            
            if isCurrentSemester {
                return matchesSearch && course.semester.contains("Winter 2023-24")
            } else {
                return matchesSearch
            }
        }
    }
}

struct SemesterFilterButton: View {
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

struct CourseCardView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if course.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            Text(course.code + " | " + course.semester)
                .font(.system(size: 14))
                .foregroundColor(Color("Accent"))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("Secondary")))
    }
}

struct Course: Identifiable {
    let id = UUID()
    let title: String
    let code: String
    let semester: String
    let isFavorite: Bool
}
