//
//  InstructionsViewModel.swift
//  VITTY
//
//  Created by Ananya George on 1/8/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class TimetableViewModel: ObservableObject {
    
    @Published var timetable: [String:[Classes]] = [:]
    @Published var goToHomeScreen: Bool = false
    
    @Published var classesCompleted: Int = 0
    
    var components = Calendar.current.dateComponents([.weekday], from: Date())
    
    private let authenticationServices = AuthService()
    
    var versionChanged: Bool = false
    
    static let daysOfTheWeek = [
        "sunday","monday", "tuesday", "wednesday", "thursday", "friday", "saturday",
    ]
    
    var timetableInfo = TimeTableInformation()
    
    private var db = Firestore.firestore()
    
    func fetchInfo(onCompletion: @escaping ()->Void){
        print("fetching user-timetable information")
        db.collection("users")
            .document(Confidential.uid)
            .getDocument { (document, error) in
                if let error = error  {
                    print("error fetching user information: \(error.localizedDescription)")
                    return
                }
                
                let data = try? document?.data(as: TimeTableInformation.self)
                guard data != nil else {
                    print("couldn't decode timetable information")
                    return
                }
                if self.timetableInfo.timetableVersion != nil {
                    if data?.timetableVersion != self.timetableInfo.timetableVersion {
                        self.versionChanged = true
                    }
                }
                self.timetableInfo = data ?? TimeTableInformation(isTimetableAvailable: nil, isUpdated: nil, timetableVersion: nil)
                print("fetched timetable info into self.timetableInfo as: \(self.timetableInfo)")
                onCompletion()
            }
    }
    
    func fetchTimetable(){
        print("fetching timetable")
        for i in (0..<7) {
            db.collection("users")
                .document(Confidential.uid)
                .collection("timetable")
                .document(TimetableViewModel.daysOfTheWeek[i])
                .collection("periods")
                .getDocuments { (documents, error) in
                    
                    if let error = error {
                        print("error fetching timetable: \(error.localizedDescription)")
                        return
                    }
                    print("day: \(TimetableViewModel.daysOfTheWeek[i])")
                    self.timetable[TimetableViewModel.daysOfTheWeek[i]] = documents?.documents.compactMap { document in
                        try? document.data(as: Classes.self)
                    } ?? []
                    
                    print("timetable now: \(self.timetable)")
                }
        }
    }
    
    func getData(){
        self.fetchInfo {
            if self.timetable.isEmpty || self.versionChanged {
                self.timetable = [:]
                self.fetchTimetable()
                self.versionChanged = false
                print("version changed?: \(self.versionChanged)")
            }
        }
    }
}

extension TimetableViewModel {
    func updateClassCompleted(){
        let today = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        let today_i = (today.weekday ?? 1) - 1
        let todayDay = TimetableViewModel.daysOfTheWeek[today_i]
        let todaysTT = self.timetable[todayDay]
        let todayClassCount = todaysTT?.count ?? 0
        self.classesCompleted = 0
        for i in (0..<todayClassCount) {
            let currentPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour,.minute], from: Date())) ?? Date()
            let endPoint = Calendar.current.date(from: Calendar.current.dateComponents([.hour,.minute], from: todaysTT?[i].endTime ?? Date())) ?? Date()
            if currentPoint > endPoint {
                self.classesCompleted += 1
            }
        }
    }
}
