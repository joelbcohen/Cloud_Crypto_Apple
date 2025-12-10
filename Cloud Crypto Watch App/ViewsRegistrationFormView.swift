//
//  RegistrationFormView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct RegistrationFormView: View {
    @Binding var serialNumber: String
    let onRegister: () -> Void
    let onGenerateSerial: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Serial Number Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Serial Number")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Enter serial number", text: $serialNumber)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .textInputAutocapitalization(.characters)
                }

                // Generate Button
                Button(action: onGenerateSerial) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Divider()
                    .padding(.vertical, 4)

                // Action Buttons
                VStack(spacing: 8) {
                    Button(action: onRegister) {
                        Text("REGISTER")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(serialNumber.isEmpty)
                }
            }
            .padding()
        }
        .navigationTitle("Register")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onCancel()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegistrationFormView(
            serialNumber: .constant(""),
            onRegister: {},
            onGenerateSerial: {},
            onCancel: {}
        )
    }
}
