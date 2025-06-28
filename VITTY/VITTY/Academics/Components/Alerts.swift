//
//  Alerts.swift
//  VITTY
//
//  Created by Rujin Devkota on 6/25/25.
//

import SwiftUI

struct DeleteNoteAlert: View {
    let noteName: String
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Delete note?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to delete '\(noteName)'?")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct DeleteFileAlert: View {
    let noteName: String
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Delete File?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to delete '\(noteName)'?")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(Color("Background"))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            .transition(.scale.combined(with: .opacity))
            Spacer()
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}
