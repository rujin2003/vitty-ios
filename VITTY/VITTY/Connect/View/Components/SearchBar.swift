//
//  SearchBar.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/25/25.
//
import SwiftUI

struct SearchBar: View {
    @Binding var searchText : String
    var body : some View{
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .font(Font.custom("Poppins-Regular", size: 14))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color("Secondary").opacity(0.5))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

