import SwiftUI
import UIKit

struct RichTextView: UIViewRepresentable {
    @Binding var attributedText: NSMutableAttributedString
    @Binding var selectedRange: NSRange
    @Binding var typingAttributes: [NSAttributedString.Key: Any]

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.typingAttributes = typingAttributes
        textView.backgroundColor = .clear
        textView.textColor = .white
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.selectedRange = selectedRange
        uiView.typingAttributes = typingAttributes
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView

        init(_ parent: RichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.selectedRange = textView.selectedRange
        }
    }
}

struct NoteEditorView: View {
    @State private var attributedText = NSMutableAttributedString(string: "Start typing here...")
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var typingAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 18),
        .foregroundColor: UIColor.white
    ]
    @State private var selectedFont: UIFont = UIFont.systemFont(ofSize: 18)
    @State private var selectedColor: Color = .white
    @State private var showFontPicker = false
    @State private var showHeadingPicker = false

//    func loadContent() {
//        
//          if let loadedMarkdown = loadMarkdownFromBackend()
//        
//        {
//              attributedText = NSMutableAttributedString(attributedString: loadedMarkdown.toAttributedString() ?? NSAttributedString(string: ""))
//          }
//      }
    
    func saveContent() {
            let markdown = attributedText.toMarkdown()
            
        }
    
    
    private let fonts: [UIFont] = [
        UIFont.systemFont(ofSize: 18),
        UIFont(name: "Times New Roman", size: 18)!,
        UIFont(name: "Helvetica", size: 18)!,
        UIFont(name: "Courier", size: 18)!
    ]

  
    private let headings: [String: CGFloat] = [
        "R1": 24,
        "R2": 20,
        "R3": 18
    ]

    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
               
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("Accent"))
                    }
                    Spacer()
                    Text("Note")
                        .foregroundColor(.white)
                        .font(.system(size: 25,weight: Font.Weight.bold))
                    Spacer()
                }
                .padding()

                RichTextView(
                    attributedText: $attributedText,
                    selectedRange: $selectedRange,
                    typingAttributes: $typingAttributes
                )
                .padding()
                .frame(maxHeight: .infinity)

            
                HStack(spacing: 20) {
                  
                    Button(action: { showFontPicker.toggle() }) {
                        Image(systemName: "textformat")
                            .foregroundColor(Color("Accent"))
                    }
                    
                   
                    Button(action: { showHeadingPicker.toggle() }) {
                        Image(systemName: "textformat.size")
                            .foregroundColor(Color("Accent"))
                    }
                    .background(
                        VStack {
                            if showHeadingPicker {
                                VStack {
                                    ForEach(Array(headings.keys.sorted()), id: \.self) { heading in
                                        Button(action: {
                                            applyHeadingStyle(heading)
                                            showHeadingPicker = false
                                        }) {
                                            Text(heading)
                                                .foregroundColor(.white)
                                                .font(.system(size: headings[heading] ?? 18))
                                        }
                                        .padding()
                                    }
                                }
                                .background(Color("Background"))
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .transition(.opacity)
                                .offset(y: -150) // Adjust this value to position the popover
                            }
                        }
                    )
                    
                  
                    Button(action: { toggleBold() }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isBoldActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isBoldActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }
                    
                    Button(action: { toggleItalic() }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isItalicActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isItalicActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }
                    
                    Button(action: { toggleUnderline() }) {
                        Image(systemName: "underline")
                            .foregroundColor(Color("Accent"))
                            .padding(8)
                            .background(isUnderlineActive() ? Color("Accent").opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isUnderlineActive() ? Color("Accent") : Color.clear, lineWidth: 1)
                            )
                    }

                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30, height: 30)
                        .onChange(of: selectedColor) { newColor in
                            applyAttribute(.foregroundColor, value: UIColor(newColor))
                        }

                    
                    Button(action: { addBulletPoints() }) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(Color("Accent"))
                    }
                }
                .padding()
                .background(Color("Background").opacity(0.8))
            }

         
            if showFontPicker {
                VStack {
                    ForEach(fonts, id: \.fontName) { font in
                        Button(action: {
                            selectedFont = font
                            applyAttribute(.font, value: font)
                            showFontPicker = false
                        }) {
                            Text(font.fontName)
                                .foregroundColor(.white)
                                .font(Font(font as CTFont))
                        }
                        .padding()
                    }
                }
                .background(Color("Background"))
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
    }


    func addBulletPoints() {
        guard selectedRange.length > 0 else { return }

        let selectedText = attributedText.attributedSubstring(from: selectedRange).string
        let lines = selectedText.components(separatedBy: "\n")
        var bulletedText = lines.map { "• \($0)" }.joined(separator: "\n")

       
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.replaceCharacters(in: selectedRange, with: bulletedText)

        attributedText = mutableAttributedString
        selectedRange.length = bulletedText.count
    }

   
    func isBoldActive() -> Bool {
        if selectedRange.length > 0 {
            if let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
        } else {
            if let font = typingAttributes[.font] as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitBold)
            }
        }
        return false
    }

    
    func isItalicActive() -> Bool {
        if selectedRange.length > 0 {
            if let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
        } else {
            if let font = typingAttributes[.font] as? UIFont {
                return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            }
        }
        return false
    }


    func isUnderlineActive() -> Bool {
        if selectedRange.length > 0 {
            if let underline = attributedText.attribute(.underlineStyle, at: selectedRange.location, effectiveRange: nil) as? Int {
                return underline == NSUnderlineStyle.single.rawValue
            }
        } else {
            if let underline = typingAttributes[.underlineStyle] as? Int {
                return underline == NSUnderlineStyle.single.rawValue
            }
        }
        return false
    }

    
    func applyHeadingStyle(_ heading: String) {
        guard let fontSize = headings[heading] else { return }
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        let newFont = UIFont(descriptor: currentFont.fontDescriptor, size: fontSize)
        applyAttribute(.font, value: newFont)
    }


    func toggleBold() {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(.traitBold) {
            traits.remove(.traitBold)
        } else {
            traits.insert(.traitBold)
        }
        if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
            applyAttribute(.font, value: newFont)
        }
    }

 
    func toggleItalic() {
        let currentFont = (selectedRange.length > 0 ? attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.font]) as? UIFont ?? UIFont.systemFont(ofSize: 18)
        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(.traitItalic) {
            traits.remove(.traitItalic)
        } else {
            traits.insert(.traitItalic)
        }
        if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
            applyAttribute(.font, value: newFont)
        }
    }


    func toggleUnderline() {
        let currentUnderline = (selectedRange.length > 0 ? attributedText.attribute(.underlineStyle, at: selectedRange.location, effectiveRange: nil) : typingAttributes[.underlineStyle]) as? Int ?? 0
        let newUnderline = currentUnderline == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
        applyAttribute(.underlineStyle, value: newUnderline)
    }

    
    func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
        if selectedRange.length > 0 {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.addAttribute(key, value: value, range: selectedRange)
            attributedText = mutableAttributedString
        } else {
            typingAttributes[key] = value
        }
    }
}

struct NoteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NoteEditorView()
    }
}
