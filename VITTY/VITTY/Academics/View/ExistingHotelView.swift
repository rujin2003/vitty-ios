//
//  ExistingHotelView.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/19/25.
//

import SwiftUI

struct ExistingHotelView: View {
    var existingNote: CreateNoteModel
    
    
    
    var body: some View {
        VStack{
            Text("Note: \(existingNote)")
            Text("Note name: \(existingNote.noteName)")
            Text("user name: \(existingNote.userName)")
            Text("course id: \(existingNote.courseId)")
            Text("course name: \(existingNote.courseName)")
            Text("note content: \(existingNote.noteContent)")
            
            Text("-----------------")
            
            if let attriString = try? AttributedString(markdown: existingNote.noteContent){
                Text("attr content: \(attriString)")
            }else{
                Text("cant do baby doll")
            }

            
            
        }
            .onAppear {
                print("existing hotel: \(existingNote)")
                
            }
    }
}
