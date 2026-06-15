//
//  ErrorView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundColor(AppColors.danger)

            Text("Something went wrong")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppColors.onSurface)

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.onSurfaceMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: onRetry) {
                Text("RETRY")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(AppColors.primary)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .padding(24)
    }
}

#Preview {
    ZStack {
        CryptoBackground()
        ErrorView(message: "Failed to connect to server", onRetry: {})
    }
    .preferredColorScheme(.dark)
}
