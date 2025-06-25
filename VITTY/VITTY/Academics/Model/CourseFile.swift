//
//  CourseFile.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/25/25.
//


import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import QuickLook
import PDFKit

// MARK: - File Model
@Model
class UploadedFile {
    var id: UUID
    var fileName: String
    var fileType: String
    var fileSize: Int64
    var courseName: String
    var courseCode: String
    var uploadDate: Date
    var localPath: String
    var thumbnailPath: String?
    var isImage: Bool
    
    init(fileName: String, fileType: String, fileSize: Int64, courseName: String, courseCode: String, localPath: String, thumbnailPath: String? = nil, isImage: Bool = false) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.courseName = courseName
        self.courseCode = courseCode
        self.uploadDate = Date()
        self.localPath = localPath
        self.thumbnailPath = thumbnailPath
        self.isImage = isImage
    }
}

