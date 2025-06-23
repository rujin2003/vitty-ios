import Foundation
import SwiftData

@Model
class  CreateNoteModel {
    var noteName: String
    var userName: String
    var courseId: String
    var courseName: String
    var noteContent: String
    var createdAt: Date

    init(noteName: String, userName: String, courseId: String, courseName: String, noteContent: String, createdAt: Date = Date()) {
        self.noteName = noteName
        self.userName = userName
        self.courseId = courseId
        self.courseName = courseName
        self.noteContent = noteContent
        self.createdAt = createdAt
    }
    enum CodingKeys: String, CodingKey {
        case noteName, userName, courseId, courseName, noteContent, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        noteName = try container.decode(String.self, forKey: .noteName)
        userName = try container.decode(String.self, forKey: .userName)
        courseId = try container.decode(String.self, forKey: .courseId)
        courseName = try container.decode(String.self, forKey: .courseName)
        noteContent = try container.decode(String.self, forKey: .noteContent)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(noteName, forKey: .noteName)
        try container.encode(userName, forKey: .userName)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(courseName, forKey: .courseName)
        try container.encode(noteContent, forKey: .noteContent)
        try container.encode(createdAt, forKey: .createdAt)
    }
}



extension CreateNoteModel {
   
    private static var plainTextCache: [String: String] = [:]
    private static var attributedStringCache: [String: NSAttributedString] = [:]
    
    var cachedPlainText: String {
        let cacheKey = "\(self.courseId)_\(self.createdAt.timeIntervalSince1970)"
        
        if let cached = Self.plainTextCache[cacheKey] {
            return cached
        }
        
        let plainText = extractPlainText()
        Self.plainTextCache[cacheKey] = plainText
        return plainText
    }
    
    var cachedAttributedString: NSAttributedString? {
        let cacheKey = "\(self.courseId)_\(self.createdAt.timeIntervalSince1970)"
        
        if let cached = Self.attributedStringCache[cacheKey] {
            return cached
        }
        
        let attributedString = extractAttributedString()
        if let attributedString = attributedString {
            Self.attributedStringCache[cacheKey] = attributedString
        }
        return attributedString
    }
    
    private func extractPlainText() -> String {
        guard let data = Data(base64Encoded: noteContent),
              let attributedString = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) else {
            return noteContent
        }
        return attributedString.string
    }
    
    private func extractAttributedString() -> NSAttributedString? {
        guard let data = Data(base64Encoded: noteContent),
              let attributedString = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) else {
            return NSAttributedString(string: noteContent)
        }
        return attributedString
    }
    
   
    static func clearCache() {
        plainTextCache.removeAll()
        attributedStringCache.removeAll()
    }
}
