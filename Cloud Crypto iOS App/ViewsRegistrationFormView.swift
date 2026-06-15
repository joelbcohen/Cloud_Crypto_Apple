//
//  RegistrationFormView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct RegistrationFormView: View {
    @Binding var serialNumber: String
    let onRegister: () -> Void
    let onGenerateSerial: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Serial Number")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.onSurfaceMuted)
                        .textCase(.uppercase)

                    TextField("Enter serial number", text: $serialNumber)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppColors.onSurface)
                        .padding(14)
                        .background(AppColors.surface.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary.opacity(0.4), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Button(action: onGenerateSerial) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text("Generate")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.secondary.opacity(0.55), lineWidth: 1)
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppColors.surface.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.primary.opacity(0.25), lineWidth: 1)
                )

                VStack(spacing: 12) {
                    Button(action: onRegister) {
                        Text("REGISTER")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(serialNumber.isEmpty ? AppColors.primary.opacity(0.4) : AppColors.primary)
                            .cornerRadius(14)
                    }
                    .disabled(serialNumber.isEmpty)

                    Button(action: onCancel) {
                        Text("CANCEL")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.onSurfaceMuted)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppColors.onSurfaceMuted.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Device Registration")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            CryptoBackground()
            RegistrationFormView(
                serialNumber: .constant(""),
                onRegister: {},
                onGenerateSerial: {},
                onCancel: {}
            )
        }
    }
    .preferredColorScheme(.dark)
}
