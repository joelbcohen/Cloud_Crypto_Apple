//
//  TransferView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct TransferView: View {
    @Binding var toAccount: String
    @Binding var amount: String
    @Binding var memo: String
    let isTransferring: Bool
    let onSend: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                fieldCard {
                    field(label: "To Account",
                          placeholder: "Account ID",
                          text: $toAccount,
                          keyboard: .numberPad,
                          autoCaps: .never)

                    field(label: "Amount",
                          placeholder: "0.00",
                          text: $amount,
                          keyboard: .decimalPad,
                          autoCaps: .never)

                    field(label: "Memo (Optional)",
                          placeholder: "Note for this transfer",
                          text: $memo,
                          keyboard: .default,
                          autoCaps: .sentences)
                }

                if isTransferring {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppColors.primary)
                        Text("SENDING...")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(AppColors.onSurface)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                } else {
                    VStack(spacing: 12) {
                        Button(action: onSend) {
                            Text("SEND")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background((toAccount.isEmpty || amount.isEmpty) ? AppColors.primary.opacity(0.4) : AppColors.primary)
                                .cornerRadius(14)
                        }
                        .disabled(toAccount.isEmpty || amount.isEmpty)

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
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Transfer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fieldCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 16) {
            content()
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
    }

    private func field(label: String,
                       placeholder: String,
                       text: Binding<String>,
                       keyboard: UIKeyboardType,
                       autoCaps: TextInputAutocapitalization) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .textCase(.uppercase)

            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .foregroundColor(AppColors.onSurface)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autoCaps)
                .autocorrectionDisabled()
                .padding(12)
                .background(AppColors.background.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.primary.opacity(0.35), lineWidth: 1)
                )
                .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            CryptoBackground()
            TransferView(
                toAccount: .constant(""),
                amount: .constant(""),
                memo: .constant(""),
                isTransferring: false,
                onSend: {},
                onCancel: {}
            )
        }
    }
    .preferredColorScheme(.dark)
}
