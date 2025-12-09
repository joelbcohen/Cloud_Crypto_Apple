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
    
    private let swipeThreshold: CGFloat = 40
    private let verticalTolerance: CGFloat = 30
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Register Device")
                    .font(.headline)
                    .padding(.top, 8)
                
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
                    
                    // Cancel button removed; swipe handles cancel/back
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
    RegistrationFormView(
        serialNumber: .constant(""),
        onRegister: {},
        onGenerateSerial: {},
        onCancel: {}
    )
}
