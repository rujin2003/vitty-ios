import Foundation
import UIKit

extension NSAttributedString {
//    func toMarkdown() -> String {
//        let mutableString = NSMutableString()login
    
//        let fullRange = NSRange(location: 0, length: self.length)
//        
//        self.enumerateAttributes(in: fullRange, options: []) { (attributes, range, _) in
//            let substring = self.attributedSubstring(from: range).string
//            
//            // Check for font attributes
//            if let font = attributes[.font] as? UIFont {
//                let traits = font.fontDescriptor.symbolicTraits
//                
//                if traits.contains(.traitBold) && traits.contains(.traitItalic) {
//                    mutableString.append("***\(substring)***")
//                } else if traits.contains(.traitBold) {
//                    mutableString.append("**\(substring)**")
//                } else if traits.contains(.traitItalic) {
//                    mutableString.append("*\(substring)*")
//                } else {
//                    mutableString.append(substring)
//                }
//            }
//            
//            // Check for underline
//            if let underline = attributes[.underlineStyle] as? Int, underline == NSUnderlineStyle.single.rawValue {
//                mutableString.insert("<u>", at: mutableString.length - substring.count)
//                mutableString.append("</u>")
//            }
//            
//            // Check for color
//            if let color = attributes[.foregroundColor] as? UIColor, color != UIColor.white {
//                let hex = color.hexString
//                mutableString.insert("<span style=\"color:\(hex)\">", at: mutableString.length - substring.count)
//                mutableString.append("</span>")
//            }
//            
//            // Handle bullet points (simple implementation)
//            if substring.hasPrefix("• ") {
//                mutableString.append("\n- \(substring.dropFirst(2))")
//            }
//        }
//        
//        return mutableString as String
//    }
}

//// MARK: - Markdown Parser Extension
//extension NSAttributedString {
//    
//    /// Converts NSAttributedString to Markdown format
//    /// Handles bold, italic, underline, font sizes, colors, and bullet points
//    func toMarkdown() -> String {
//           var md = ""
//           let fullText = string as NSString
//           let lines = fullText.components(separatedBy: "\n")
//           var location = 0
//           
//           for (i, line) in lines.enumerated() {
//               let length = (line as NSString).length
//               
//               // 1) Empty line? just emit newline
//               if length == 0 {
//                   md += "\n"
//                   location += 1   // account for the stripped '\n'
//                   continue
//               }
//               
//               let lineRange = NSRange(location: location, length: length)
//               
//               // 2) Heading detection based on font size at start of line
//               if let font = attribute(.font, at: location, effectiveRange: nil) as? UIFont {
//                   switch font.pointSize {
//                   case let s where s > 24: md += "# ";
//                   case let s where s > 20: md += "## ";
//                   case let s where s > 18: md += "### ";
//                   default: break
//                   }
//               }
//               
//               // 3) Enumerate each run within that line
//               enumerateAttributes(in: lineRange, options: []) { attrs, runRange, _ in
//                   var substr = attributedSubstring(from: runRange).string
//                   
//                   // Escape literal Markdown markers so we don't mangle user-typed '*' etc.
//                   substr = substr
//                     .replacingOccurrences(of: "\\", with: "\\\\")
//                     .replacingOccurrences(of: "*",  with: "\\*")
//                     .replacingOccurrences(of: "_",  with: "\\_")
//                   
//                   // Build wrappers
//                   var prefix = "", suffix = ""
//                   
//                   // Bold / Italic
//                   if let font = attrs[.font] as? UIFont {
//                       let traits = font.fontDescriptor.symbolicTraits
//                       if traits.contains(.traitBold)   { prefix += "**"; suffix = "**" + suffix }
//                       if traits.contains(.traitItalic) { prefix += "*";  suffix = "*"  + suffix }
//                   }
//                   
//                   // Underline
//                   if let u = attrs[.underlineStyle] as? Int,
//                      u == NSUnderlineStyle.single.rawValue {
//                       prefix = "<u>" + prefix
//                       suffix += "</u>"
//                   }
//                   
//                   // Color
//                   if let color = attrs[.foregroundColor] as? UIColor,
//                      !isDefaultTextColor(color) {
//                       let hex = colorToHex(color)
//                       substr = "<span style=\"color:\(hex)\">\(substr)</span>"
//                   }
//                   
//                   md += prefix + substr + suffix
//               }
//               
//               // 4) Re-append the newline (except after the last line)
//               if i < lines.count - 1 {
//                   md += "\n"
//               }
//               location += length + 1
//           }
//           
//           return md
//       }
//    
//    // MARK: - Helper Methods
//    
//    private func colorToHex(_ color: UIColor) -> String {
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        
//        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        
//        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
//        return String(format: "#%06x", rgb)
//    }
//    
//    private func isDefaultTextColor(_ color: UIColor) -> Bool {
//        // Check if color is white or default text color
//        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
//        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        return red > 0.9 && green > 0.9 && blue > 0.9 // Close to white
//    }
//    
//    private func isNextCharacterBold(at index: Int) -> Bool {
//        guard index < self.length else { return false }
//        if let font = self.attribute(.font, at: index, effectiveRange: nil) as? UIFont {
//            return font.fontDescriptor.symbolicTraits.contains(.traitBold)
//        }
//        return false
//    }
//    
//    private func isNextCharacterItalic(at index: Int) -> Bool {
//        guard index < self.length else { return false }
//        if let font = self.attribute(.font, at: index, effectiveRange: nil) as? UIFont {
//            return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
//        }
//        return false
//    }
//    
//    private func isNextCharacterUnderlined(at index: Int) -> Bool {
//        guard index < self.length else { return false }
//        if let underline = self.attribute(.underlineStyle, at: index, effectiveRange: nil) as? Int {
//            return underline == NSUnderlineStyle.single.rawValue
//        }
//        return false
//    }
//}

// MARK: - Markdown to NSAttributedString Parser
extension String {
    
    /// Converts Markdown string to NSAttributedString
    /// Handles bold, italic, underline, headings, colors, and bullet points
    func fromMarkdown() -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        let lines = self.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index > 0 {
                result.append(NSAttributedString(string: "\n"))
            }
            
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            let processedLine = processMarkdownLine(line)
            result.append(processedLine)
        }
        
        return result
    }
    
    private func processMarkdownLine(_ line: String) -> NSAttributedString {
        var workingLine = line
        let result = NSMutableAttributedString()
        

        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        
    
        if workingLine.hasPrefix("### ") {
            workingLine = String(workingLine.dropFirst(4))
            attributes[.font] = UIFont.boldSystemFont(ofSize: 20)
        } else if workingLine.hasPrefix("## ") {
            workingLine = String(workingLine.dropFirst(3))
            attributes[.font] = UIFont.boldSystemFont(ofSize: 24)
        } else if workingLine.hasPrefix("# ") {
            workingLine = String(workingLine.dropFirst(2))
            attributes[.font] = UIFont.boldSystemFont(ofSize: 28)
        }
        
        
        if workingLine.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
            workingLine = workingLine.replacingOccurrences(of: "- ", with: "• ", options: [], range: workingLine.range(of: "- "))
        }
        
      
        let processedString = processInlineFormatting(workingLine, baseAttributes: attributes)
        result.append(processedString)
        
        return result
    }
    
    private func processInlineFormatting(_ text: String, baseAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        var currentIndex = text.startIndex
        var currentAttributes = baseAttributes
        
        while currentIndex < text.endIndex {
           
            if let colorRange = findColorSpan(in: text, from: currentIndex) {
              
                if currentIndex < colorRange.range.lowerBound {
                    let beforeText = String(text[currentIndex..<colorRange.range.lowerBound])
                    result.append(NSAttributedString(string: beforeText, attributes: currentAttributes))
                }
                
             
                var colorAttributes = currentAttributes
                colorAttributes[.foregroundColor] = colorRange.color
                result.append(NSAttributedString(string: colorRange.text, attributes: colorAttributes))
                
                currentIndex = colorRange.range.upperBound
                continue
            }
            
           
            if text[currentIndex...].hasPrefix("<u>") {
                if let endIndex = text.range(of: "</u>", range: currentIndex..<text.endIndex) {
                    let startTagEnd = text.index(currentIndex, offsetBy: 3)
                    let underlinedText = String(text[startTagEnd..<endIndex.lowerBound])
                    
                    var underlineAttributes = currentAttributes
                    underlineAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    result.append(NSAttributedString(string: underlinedText, attributes: underlineAttributes))
                    
                    currentIndex = text.index(endIndex.upperBound, offsetBy: 0)
                    continue
                }
            }
            
    
            let (formattedString, newIndex) = processBoldItalic(text, from: currentIndex, attributes: currentAttributes)
            result.append(formattedString)
            currentIndex = newIndex
        }
        
        return result
    }
    
    private func findColorSpan(in text: String, from startIndex: String.Index) -> (range: Range<String.Index>, text: String, color: UIColor)? {
        let searchText = String(text[startIndex...])
        let pattern = #"<span style="color:(#[0-9A-Fa-f]{6})">([^<]*)</span>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsRange = NSRange(searchText.startIndex..<searchText.endIndex, in: searchText)
        
        if let match = regex.firstMatch(in: searchText, range: nsRange) {
            let colorRange = Range(match.range(at: 1), in: searchText)!
            let textRange = Range(match.range(at: 2), in: searchText)!
            let fullRange = Range(match.range, in: searchText)!
            
            let colorHex = String(searchText[colorRange])
            let spanText = String(searchText[textRange])
            let color = colorFromHex(colorHex) ?? UIColor.white
            
            let adjustedRange = text.index(startIndex, offsetBy: fullRange.lowerBound.utf16Offset(in: searchText))..<text.index(startIndex, offsetBy: fullRange.upperBound.utf16Offset(in: searchText))
            
            return (adjustedRange, spanText, color)
        }
        
        return nil
    }
    
    private func processBoldItalic(_ text: String, from startIndex: String.Index, attributes: [NSAttributedString.Key: Any]) -> (NSAttributedString, String.Index) {
        var currentIndex = startIndex
        var currentAttributes = attributes
        let result = NSMutableAttributedString()
        
        // Find next formatting marker
        let remainingText = String(text[currentIndex...])
        let boldPattern = #"\*\*([^*]+)\*\*"#
        let italicPattern = #"\*([^*]+)\*"#
        
      
        if let boldRegex = try? NSRegularExpression(pattern: boldPattern),
           let boldMatch = boldRegex.firstMatch(in: remainingText, range: NSRange(remainingText.startIndex..<remainingText.endIndex, in: remainingText)) {
            
            let matchRange = Range(boldMatch.range, in: remainingText)!
            let textRange = Range(boldMatch.range(at: 1), in: remainingText)!
            
            
            if matchRange.lowerBound > remainingText.startIndex {
                let beforeText = String(remainingText[remainingText.startIndex..<matchRange.lowerBound])
                result.append(NSAttributedString(string: beforeText, attributes: currentAttributes))
            }
            
          
            let boldText = String(remainingText[textRange])
            var boldAttributes = currentAttributes
            if let font = boldAttributes[.font] as? UIFont {
                boldAttributes[.font] = UIFont.boldSystemFont(ofSize: font.pointSize)
            }
            result.append(NSAttributedString(string: boldText, attributes: boldAttributes))
            
            currentIndex = text.index(startIndex, offsetBy: matchRange.upperBound.utf16Offset(in: remainingText))
        }
        // Check for italic
        else if let italicRegex = try? NSRegularExpression(pattern: italicPattern),
                let italicMatch = italicRegex.firstMatch(in: remainingText, range: NSRange(remainingText.startIndex..<remainingText.endIndex, in: remainingText)) {
            
            let matchRange = Range(italicMatch.range, in: remainingText)!
            let textRange = Range(italicMatch.range(at: 1), in: remainingText)!
            
            // Add text before match
            if matchRange.lowerBound > remainingText.startIndex {
                let beforeText = String(remainingText[remainingText.startIndex..<matchRange.lowerBound])
                result.append(NSAttributedString(string: beforeText, attributes: currentAttributes))
            }
            
            // Add italic text
            let italicText = String(remainingText[textRange])
            var italicAttributes = currentAttributes
            if let font = italicAttributes[.font] as? UIFont {
                italicAttributes[.font] = UIFont.italicSystemFont(ofSize: font.pointSize)
            }
            result.append(NSAttributedString(string: italicText, attributes: italicAttributes))
            
            currentIndex = text.index(startIndex, offsetBy: matchRange.upperBound.utf16Offset(in: remainingText))
        }
        // No formatting found, add single character
        else {
            let char = String(text[currentIndex])
            result.append(NSAttributedString(string: char, attributes: currentAttributes))
            currentIndex = text.index(after: currentIndex)
        }
        
        return (result, currentIndex)
    }
    
    private func colorFromHex(_ hex: String) -> UIColor? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        return UIColor(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
