//
//  LoadingView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(AppColors.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.onSurfaceMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ZStack {
        CryptoBackground()
        LoadingView()
    }
    .preferredColorScheme(.dark)
}
