//
//  QrCode.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/24/25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI


struct QRCodeModalView: View {
    let groupCode: String
    let circleName: String
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
              
                HStack {
                    Text("Circle QR Code")
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }
                
                
                VStack(spacing: 8) {
                    Text(circleName)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
                    Text("Circle ID: \(groupCode)")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                
               
                if let qrImage = generateQRCode(from: createInvitationLink()) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .cornerRadius(12)
                        .overlay(
                            Text("QR Code\nGeneration Failed")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        )
                }
                
                
                Text("Share this code for others to join your circle")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
               
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Invitation")
                    }
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color("Accent"))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: 300)
            .padding(24)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createInvitationLink(), "Join my circle '\(circleName)' on VITTY!"])
        }
    }
    
    private func createInvitationLink() -> String {
      
        let baseURL = "https://vitty.app/invite"
        let encodedCircleName = circleName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? circleName
        return "\(baseURL)/circles/sendRequest/\(groupCode)&circleName=\(encodedCircleName)"
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scaleX = 200 / outputImage.extent.size.width
            let scaleY = 200 / outputImage.extent.size.height
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
