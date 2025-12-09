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

    @State private var dragOffset: CGFloat = 0

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
                }
            }
            .padding()
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only allow rightward swipes
                    if gesture.translation.width > 0 {
                        dragOffset = gesture.translation.width
                    }
                }
                .onEnded { gesture in
                    // Trigger cancel if swipe distance > 50 or velocity is high enough
                    if gesture.translation.width > 50 || gesture.predictedEndTranslation.width > 100 {
                        onCancel()
                    }
                    // Reset offset
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = 0
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
