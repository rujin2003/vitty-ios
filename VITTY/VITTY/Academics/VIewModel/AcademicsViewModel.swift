//
//  AcademicsViewModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/27/25.
//

import SwiftUI
import OSLog
import Alamofire


@Observable class AcademicsViewModel {
    
    
    var notes = [CreateNoteModel]()
       var loading = false
       var error = false

       private let logger = Logger(
           subsystem: Bundle.main.bundleIdentifier!,
           category: String(describing: AcademicsViewModel.self)
       )
    
}
