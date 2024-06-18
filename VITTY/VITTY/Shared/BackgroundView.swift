//
//  BackgroundView.swift
//  VITTY
//
//  Created by Chandram Dutta on 11/06/24.
//

import SwiftUI

struct BackgroundView: View {

	let background: String

	var body: some View {
		Image(background)
			.resizable()
			.ignoresSafeArea(.all)
	}
}

#Preview {
	BackgroundView(background: "HomeBG")
}
