//
//  FileUpload.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/25/25.
//

import SwiftUI
import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import QuickLook
import PDFKit

// MARK: - File Upload View
struct FileUploadView: View {
    let courseName: String
    let courseCode: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var showDocumentPicker = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var showSuccessAlert = false
    @State private var uploadedCount = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 48))
                            .foregroundColor(Color("Secondary"))
                        
                        Text("Upload Files")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Add images and documents to \(courseName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                  
                    VStack(spacing: 16) {
                        Button(action: {
                                                   showCamera = true
                                               }) {
                                                   UploadOptionCard(
                                                       icon: "camera.fill",
                                                       title: "Take Photo",
                                                       description: "Capture new photos with camera",
                                                       color: .orange
                                                   )
                                               }
                                               .disabled(isUploading)
                      
                        PhotosPicker(
                            selection: $selectedImages,
                            maxSelectionCount: 10,
                            matching: .images
                        ) {
                            UploadOptionCard(
                                icon: "photo.on.rectangle.angled",
                                title: "Upload Images",
                                description: "Take photos or select from gallery",
                                color: .blue
                            )
                        }
                        .disabled(isUploading)
                        
                       
                        Button(action: {
                            showDocumentPicker = true
                        }) {
                            UploadOptionCard(
                                icon: "doc.fill",
                                title: "Upload Documents",
                                description: "Select PDF, Word, or other files",
                                color: .green
                            )
                        }
                        .disabled(isUploading)
                    }
                    
                  
                    if isUploading {
                        VStack(spacing: 12) {
                            ProgressView(value: uploadProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color("Secondary")))
                            
                            Text("Uploading files... (\(Int(uploadProgress * 100))%)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Upload Files")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .disabled(isUploading)
                }
            }
        }
        .onChange(of: selectedImages) { _, newItems in
            if !newItems.isEmpty {
                uploadImages(newItems)
            }
        }.onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                uploadCapturedImage(image)
            }
        }
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.pdf, .plainText, .rtf, .rtfd, .data, .item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                uploadDocuments(urls)
            case .failure(let error):
                errorMessage = "Error selecting documents: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
        .alert("Upload Complete", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully uploaded \(uploadedCount) file(s)")
        }
        .alert("Upload Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func uploadImages(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        
        isUploading = true
        uploadProgress = 0
        uploadedCount = 0
        
        Task {
            for (index, item) in items.enumerated() {
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        let timestamp = Int(Date().timeIntervalSince1970)
                        let fileName = "image_\(timestamp)_\(index).jpg"
                        
                        if let savedPath = FileManagerHelper.shared.saveFile(
                            data: data,
                            fileName: fileName,
                            courseCode: courseCode
                        ) {
                            let thumbnailPath = FileManagerHelper.shared.generateThumbnail(
                                for: data,
                                courseCode: courseCode,
                                fileName: fileName
                            )
                            
                            let uploadedFile = UploadedFile(
                                fileName: fileName,
                                fileType: "jpg",
                                fileSize: Int64(data.count),
                                courseName: courseName,
                                courseCode: courseCode,
                                localPath: savedPath,
                                thumbnailPath: thumbnailPath,
                                isImage: true
                            )
                            
                            await MainActor.run {
                                modelContext.insert(uploadedFile)
                                uploadedCount += 1
                            }
                        }
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to process image: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
                
                await MainActor.run {
                    uploadProgress = Double(index + 1) / Double(items.count)
                }
            }
            
            await MainActor.run {
                isUploading = false
                selectedImages = []
                
                if uploadedCount > 0 {
                    do {
                        try modelContext.save()
                        showSuccessAlert = true
                    } catch {
                        errorMessage = "Error saving files: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            }
        }
    }
    
    private func uploadDocuments(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        isUploading = true
        uploadProgress = 0
        uploadedCount = 0
        
        Task {
            for (index, url) in urls.enumerated() {
                var canAccess = false
                
                if url.startAccessingSecurityScopedResource() {
                    canAccess = true
                }
                
                defer {
                    if canAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let fileName = url.lastPathComponent
                    let fileType = url.pathExtension
                    
                    if let savedPath = FileManagerHelper.shared.saveFile(
                        data: data,
                        fileName: fileName,
                        courseCode: courseCode
                    ) {
                        let uploadedFile = UploadedFile(
                            fileName: fileName,
                            fileType: fileType,
                            fileSize: Int64(data.count),
                            courseName: courseName,
                            courseCode: courseCode,
                            localPath: savedPath,
                            isImage: false
                        )
                        
                        await MainActor.run {
                            modelContext.insert(uploadedFile)
                            uploadedCount += 1
                        }
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to process document \(url.lastPathComponent): \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
                
                await MainActor.run {
                    uploadProgress = Double(index + 1) / Double(urls.count)
                }
            }
            
            await MainActor.run {
                isUploading = false
                
                if uploadedCount > 0 {
                    do {
                        try modelContext.save()
                        showSuccessAlert = true
                    } catch {
                        errorMessage = "Error saving files: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            }
        }
    }
    private func uploadCapturedImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process captured image"
            showErrorAlert = true
            return
        }
        
        isUploading = true
        uploadProgress = 0
        uploadedCount = 0
        
        Task {
            let timestamp = Int(Date().timeIntervalSince1970)
            let fileName = "camera_\(timestamp).jpg"
            
            if let savedPath = FileManagerHelper.shared.saveFile(
                data: imageData,
                fileName: fileName,
                courseCode: courseCode
            ) {
                let thumbnailPath = FileManagerHelper.shared.generateThumbnail(
                    for: imageData,
                    courseCode: courseCode,
                    fileName: fileName
                )
                
                let uploadedFile = UploadedFile(
                    fileName: fileName,
                    fileType: "jpg",
                    fileSize: Int64(imageData.count),
                    courseName: courseName,
                    courseCode: courseCode,
                    localPath: savedPath,
                    thumbnailPath: thumbnailPath,
                    isImage: true
                )
                
                await MainActor.run {
                    modelContext.insert(uploadedFile)
                    uploadedCount = 1
                    uploadProgress = 1.0
                    isUploading = false
                    capturedImage = nil
                    
                    do {
                        try modelContext.save()
                        showSuccessAlert = true
                    } catch {
                        errorMessage = "Error saving captured image: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            } else {
                await MainActor.run {
                    isUploading = false
                    capturedImage = nil
                    errorMessage = "Failed to save captured image"
                    showErrorAlert = true
                }
            }
        }
    }
    

}
// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.cameraCaptureMode = .photo
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.capturedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.capturedImage = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


// MARK: - Upload Option Card
struct UploadOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - File Gallery View
struct FileGalleryView: View {
    let courseCode: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var files: [UploadedFile]
    @State private var selectedFilter: FileFilter = .all
    @State private var showDeleteAlert = false
    @State private var fileToDelete: UploadedFile?
    @State private var selectedFile: UploadedFile?
    @State private var showFileViewer = false
    
    enum FileFilter: String, CaseIterable {
        case all = "All"
        case images = "Images"
        case documents = "Documents"
        
        var icon: String {
            switch self {
            case .all: return "folder"
            case .images: return "photo"
            case .documents: return "doc"
            }
        }
    }
    
    init(courseCode: String) {
        self.courseCode = courseCode
        let predicate = #Predicate<UploadedFile> { file in
            file.courseCode == courseCode
        }
        _files = Query(
            FetchDescriptor(
                predicate: predicate,
                sortBy: [SortDescriptor(\.uploadDate, order: .reverse)]
            )
        )
    }
    
    private var filteredFiles: [UploadedFile] {
        switch selectedFilter {
        case .all:
            return files
        case .images:
            return files.filter { $0.isImage }
        case .documents:
            return files.filter { !$0.isImage }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                  
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FileFilter.allCases, id: \.self) { filter in
                                FilterTab(
                                    filter: filter,
                                    isSelected: selectedFilter == filter
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                   
                    if filteredFiles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: selectedFilter.icon)
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No \(selectedFilter.rawValue.lowercased()) found")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Upload some files to get started")
                                .foregroundColor(.gray.opacity(0.7))
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(filteredFiles, id: \.id) { file in
                                    FileCard(file: file) {
                                        selectedFile = file
                                        showFileViewer = true
                                    } onDelete: {
                                        fileToDelete = file
                                        showDeleteAlert = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Files")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(filteredFiles.count) files")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .alert("Delete File", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteFile()
            }
        } message: {
            Text("Are you sure you want to delete '\(fileToDelete?.fileName ?? "")'?")
        }
        .sheet(isPresented: $showFileViewer) {
            if let file = selectedFile {
                EnhancedFileViewerSheet(file: file)
            }
        }
    }
    
    private func deleteFile() {
        guard let file = fileToDelete else { return }
        
        
        FileManagerHelper.shared.deleteFile(at: file.localPath)
        if let thumbnailPath = file.thumbnailPath {
            FileManagerHelper.shared.deleteFile(at: thumbnailPath)
        }
        
       
        modelContext.delete(file)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting file: \(error)")
        }
        
        fileToDelete = nil
    }
}

// MARK: - Filter Tab
struct FilterTab: View {
    let filter: FileGalleryView.FileFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14))
                
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color("Secondary") : Color.white.opacity(0.1))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
        }
    }
}
// MARK: - File Card
struct FileCard: View {
    let file: UploadedFile
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var imageLoadError = false
    @State private var showActionSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            if file.isImage && !imageLoadError {
                Group {
                    if let thumbnailPath = file.thumbnailPath,
                       let thumbnailURL = getValidFileURL(from: thumbnailPath) {
                        AsyncImage(url: thumbnailURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        }
                    } else if let fileURL = getValidFileURL(from: file.localPath) {
                        AsyncImage(url: fileURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        }
                    } else {
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                            .overlay(
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                    Text("File not found")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            )
                    }
                }
                .frame(height: 120)
                .clipped()
                .onAppear {
                    
                    if getValidFileURL(from: file.localPath) == nil {
                        imageLoadError = true
                    }
                }
            } else {
                Rectangle()
                    .fill(getFileTypeColor(file.fileType).opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: getFileTypeIcon(file.fileType))
                                .font(.system(size: 32))
                                .foregroundColor(getFileTypeColor(file.fileType))
                            
                            Text(file.fileType.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(getFileTypeColor(file.fileType))
                        }
                    )
            }
            
         
            VStack(alignment: .leading, spacing: 4) {
                Text(file.fileName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(FileManagerHelper.shared.formatFileSize(file.fileSize))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(file.uploadDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
          
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
         
            showActionSheet = true
        }
        .confirmationDialog("File Options", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Share") {
                shareFile()
            }
            
            Button("Delete", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("Choose an action for \(file.fileName)")
        }
    }
    
    // MARK: - Helper Methods
    
   
    private func getValidFileURL(from storedPath: String) -> URL? {
        
        if FileManager.default.fileExists(atPath: storedPath) {
            return URL(fileURLWithPath: storedPath)
        }
        
      
        let fileName = URL(fileURLWithPath: storedPath).lastPathComponent
        let currentDocumentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let courseDir = currentDocumentsDir.appendingPathComponent("Courses/\(file.courseCode)")
        let reconstructedURL = courseDir.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: reconstructedURL.path) {
            return reconstructedURL
        }
        
        return nil
    }
    
   
    private func shareFile() {
        guard let fileURL = getValidFileURL(from: file.localPath) else {
            print("Cannot share file: File not found")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
       
    }
    
    private func getFileTypeIcon(_ fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf":
            return "doc.richtext.fill"
        case "txt":
            return "doc.text.fill"
        case "rtf", "rtfd":
            return "doc.richtext.fill"
        case "doc", "docx":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func getFileTypeColor(_ fileType: String) -> Color {
        switch fileType.lowercased() {
        case "pdf":
            return .red
        case "txt":
            return .blue
        case "rtf", "rtfd":
            return .purple
        case "doc", "docx":
            return .blue
        case "jpg", "jpeg", "png", "gif", "heic":
            return .green
        default:
            return .gray
        }
    }
}

// MARK: - Updated FileManagerHelper
extension FileManagerHelper {
    
    func updateFilePathsIfNeeded(for file: UploadedFile) -> Bool {
       
        if fileExists(at: file.localPath) {
            return true
        }
        
        
        let fileName = URL(fileURLWithPath: file.localPath).lastPathComponent
        let courseDir = createCourseDirectory(courseCode: file.courseCode)
        let newPath = courseDir.appendingPathComponent(fileName).path
        
        if fileExists(at: newPath) {
           
            return true
        }
        
        return false
    }
}

struct EnhancedFileViewerSheet: View {
    let file: UploadedFile
    
    @Environment(\.dismiss) private var dismiss
    @State private var fileData: Data?
    @State private var isLoading = true
    @State private var showShareSheet = false
    @State private var loadError: String?
    @State private var showQuickLook = false
    @State private var temporaryFileURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Loading file...")
                            .foregroundColor(.gray)
                    }
                } else if let error = loadError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Unable to load file")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else if let data = fileData {
                    contentView(for: data)
                }
            }
            .navigationTitle(file.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if file.fileType.lowercased() == "pdf" {
                            Button("Open") {
                                showQuickLook = true
                            }
                            .foregroundColor(.white)
                        }
                        
                        Button("Share") {
                            showShareSheet = true
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadFileData()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = temporaryFileURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showQuickLook) {
            if let url = temporaryFileURL {
                QuickLookView(url: url)
            }
        }
    }
    
    @ViewBuilder
    private func contentView(for data: Data) -> some View {
        if file.isImage, let image = UIImage(data: data) {
           
            ScrollView([.horizontal, .vertical]) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
        } else if file.fileType.lowercased() == "pdf" {
            
            PDFViewerWrapper(data: data)
        } else if file.fileType.lowercased() == "txt" {
            
            if let text = String(data: data, encoding: .utf8) {
                ScrollView {
                    Text(text)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                fileInfoView(data: data)
            }
        } else {
            
            fileInfoView(data: data)
        }
    }
    
    @ViewBuilder
    private func fileInfoView(data: Data) -> some View {
        VStack(spacing: 20) {
            Image(systemName: getFileTypeIcon(file.fileType))
                .font(.system(size: 64))
                .foregroundColor(getFileTypeColor(file.fileType))
            
            Text(file.fileName)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("File size: \(FileManagerHelper.shared.formatFileSize(file.fileSize))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Type: \(file.fileType.uppercased())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Uploaded: \(file.uploadDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button("Open with External App") {
                showQuickLook = true
            }
            .padding()
            .background(Color("Secondary"))
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func loadFileData() {
        Task {
           
            let data = FileManagerHelper.shared.loadFileWithFallback(from: file.localPath, courseCode: file.courseCode)
            
            await MainActor.run {
                if let data = data {
                    fileData = data
                    createTemporaryFile(data: data)
                } else {
                    loadError = "File not found or corrupted"
                }
                isLoading = false
            }
        }
    }
    
    private func createTemporaryFile(data: Data) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(file.fileName)
        
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try data.write(to: tempURL)
            temporaryFileURL = tempURL
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }
    
    private func getFileTypeIcon(_ fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf":
            return "doc.richtext.fill"
        case "txt":
            return "doc.text.fill"
        case "rtf", "rtfd":
            return "doc.richtext.fill"
        case "doc", "docx":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func getFileTypeColor(_ fileType: String) -> Color {
        switch fileType.lowercased() {
        case "pdf":
            return .red
        case "txt":
            return .blue
        case "rtf", "rtfd":
            return .purple
        case "doc", "docx":
            return .blue
        case "jpg", "jpeg", "png", "gif", "heic":
            return .green
        default:
            return .gray
        }
    }
}
struct PDFViewerWrapper: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.backgroundColor = UIColor.clear
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        
    }
}

// MARK: - QuickLook View
struct QuickLookView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookView
        
        init(_ parent: QuickLookView) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }
    }
}

// MARK: - Enhanced FileManagerHelper Extension
extension FileManagerHelper {
    
   
    func loadFileWithFallback(from storedPath: String, courseCode: String) -> Data? {
        
        if fileExists(at: storedPath), let data = loadFile(from: storedPath) {
            return data
        }
        
      
        let fileName = URL(fileURLWithPath: storedPath).lastPathComponent
        let courseDir = createCourseDirectory(courseCode: courseCode)
        let reconstructedPath = courseDir.appendingPathComponent(fileName).path
        
        if fileExists(at: reconstructedPath), let data = loadFile(from: reconstructedPath) {
            return data
        }
        
        
        return findAndLoadFile(fileName: fileName, in: courseDir)
    }
    
   
    private func findAndLoadFile(fileName: String, in directory: URL) -> Data? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            for fileURL in contents {
                if fileURL.lastPathComponent == fileName {
                    return try? Data(contentsOf: fileURL)
                }
            }
        } catch {
            print("Error searching directory: \(error)")
        }
        
        return nil
    }
    
   
    func updateStoredFilePaths(files: [UploadedFile], modelContext: ModelContext) {
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
                print("Updated \(files.count) file paths")
            } catch {
                print("Error updating file paths: \(error)")
            }
        }
    }
}


// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
       
    }
}
