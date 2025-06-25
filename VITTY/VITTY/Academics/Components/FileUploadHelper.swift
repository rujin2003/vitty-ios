//
//  FileUploadHelper.swift
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

// MARK: - File Manager Helper
class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    private init() {}
    
    var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func createCourseDirectory(courseCode: String) -> URL {
        let courseDir = documentsDirectory.appendingPathComponent("Courses/\(courseCode)")
        try? FileManager.default.createDirectory(at: courseDir, withIntermediateDirectories: true)
        return courseDir
    }
    
    func saveFile(data: Data, fileName: String, courseCode: String) -> String? {
        let courseDir = createCourseDirectory(courseCode: courseCode)
        let fileURL = courseDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    func loadFile(from path: String) -> Data? {
        return FileManager.default.contents(atPath: path)
    }
    
   
    func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func generateThumbnail(for imageData: Data, courseCode: String, fileName: String) -> String? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let thumbnailSize = CGSize(width: 150, height: 150)
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        
        let thumbnailImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
        
        guard let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.7) else { return nil }
        
        let thumbnailFileName = "thumb_\(fileName)"
        return saveFile(data: thumbnailData, fileName: thumbnailFileName, courseCode: courseCode)
    }
    
    func deleteFile(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
    
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}


extension FileManagerHelper {
    
    
    func getValidFileURL(from storedPath: String, courseCode: String) -> URL? {
        
        if FileManager.default.fileExists(atPath: storedPath) {
            return URL(fileURLWithPath: storedPath)
        }
        
       
        let fileName = URL(fileURLWithPath: storedPath).lastPathComponent
        let courseDir = createCourseDirectory(courseCode: courseCode)
        let reconstructedURL = courseDir.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: reconstructedURL.path) {
            return reconstructedURL
        }
        
        return nil
    }
    
 
    func updateFilePathsIfNeeded(files: [UploadedFile], modelContext: ModelContext) {
        var hasChanges = false
        
        for file in files {
           
            if !fileExists(at: file.localPath) {
              
                let fileName = URL(fileURLWithPath: file.localPath).lastPathComponent
                let courseDir = createCourseDirectory(courseCode: file.courseCode)
                let newPath = courseDir.appendingPathComponent(fileName).path
                
                if fileExists(at: newPath) {
                  
                    file.localPath = newPath
                    hasChanges = true
                }
            }
            
            
            if let thumbnailPath = file.thumbnailPath, !fileExists(at: thumbnailPath) {
                let thumbnailFileName = URL(fileURLWithPath: thumbnailPath).lastPathComponent
                let courseDir = createCourseDirectory(courseCode: file.courseCode)
                let newThumbnailPath = courseDir.appendingPathComponent(thumbnailFileName).path
                
                if fileExists(at: newThumbnailPath) {
                    file.thumbnailPath = newThumbnailPath
                    hasChanges = true
                }
            }
        }
        
     
        if hasChanges {
            do {
                try modelContext.save()
                print("Updated file paths for \(files.count) files")
            } catch {
                print("Error updating file paths: \(error)")
            }
        }
    }
    
  
}
