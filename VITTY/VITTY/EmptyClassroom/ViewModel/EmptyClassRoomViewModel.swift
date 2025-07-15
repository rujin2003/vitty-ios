//
//  EmptyClassRoomViewModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 2/27/25.
//

import Foundation

@MainActor
class EmptyClassroomViewModel: ObservableObject {
    @Published var emptyClassrooms: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isGenerating: Bool = false
    private var currentSlot: String = "A1"

    func fetchEmptyClassrooms(slot: String, authToken: String) async {
        guard !slot.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        isGenerating = false
        currentSlot = slot
        
        do {
            let classrooms = try await EmptyClassRoomAPIService.shared.getEmptyClassrooms(slot: slot, authToken: authToken)
            emptyClassrooms = classrooms
            isGenerating = false
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        let errorDescription = error.localizedDescription.lowercased()
        
        // Check if this is a server error (likely generation in progress)
        if let nsError = error as NSError?,
           nsError.code >= 500 ||
           errorDescription.contains("contact vitty support") ||
           errorDescription.contains("failed to parse error response") ||
           errorDescription.contains("generating") ||
           errorDescription.contains("server error") {
            
            // Show generation state instead of error
            isGenerating = true
            errorMessage = nil
        } else {
            // Only show actual errors for client-side issues
            isGenerating = false
            errorMessage = "Failed to load empty classrooms: \(error.localizedDescription)"
        }
    }
    
    func reload(slot: String, authToken: String) {
        Task {
            await fetchEmptyClassrooms(slot: slot, authToken: authToken)
        }
    }
}
