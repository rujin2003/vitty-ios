//
//  GetSchemas.swift
//  VITTY
//
//  Created by Rujin Devkota on 8/6/25.
//

import SwiftUI
import SwiftData

class GetSchemas{
    
   static func getSharedContainer() -> ModelContainer? {
        let appGroupContainerID = "\(AppConstants.VITTYappgroup)"
        
      
        let schema = Schema([TimeTable.self, Remainder.self, CreateNoteModel.self, UploadedFile.self])
        
        let config = ModelConfiguration(
            appGroupContainerID,
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
          
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("Failed to create shared container: \(error)")
            return nil
        }
    }
    
}
