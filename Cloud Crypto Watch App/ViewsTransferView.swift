//
//  TransferView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct TransferView: View {
    @Binding var toAccount: String
    @Binding var amount: String
    @Binding var memo: String
    let isTransferring: Bool
    let onSend: () -> Void
    let onCancel: () -> Void
    
    private let swipeThreshold: CGFloat = 40
    private let verticalTolerance: CGFloat = 30
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Transfer")
                    .font(.headline)
                    .padding(.top, 8)
                
                // To Account Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("To Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Account ID", text: $toAccount)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                // Amount Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("0.00", text: $amount)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Memo Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memo (Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Note for this transfer", text: $memo)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .textInputAutocapitalization(.sentences)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Action Buttons
                VStack(spacing: 8) {
                    if isTransferring {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: onSend) {
                            Text("SEND")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(toAccount.isEmpty || amount.isEmpty)
                        
                        // Cancel button removed; swipe handles cancel/back
                    }
                }
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = abs(value.translation.height)
                    if horizontal > swipeThreshold && vertical < verticalTolerance {
                        onCancel()
                    }
                }
        )
    }
}

#Preview {
    TransferView(
        toAccount: .constant(""),
        amount: .constant(""),
        memo: .constant(""),
        isTransferring: false,
        onSend: {},
        onCancel: {}
    )
}
