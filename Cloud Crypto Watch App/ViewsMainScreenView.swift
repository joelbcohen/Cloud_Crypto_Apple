//
//  MainScreenView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct MainScreenView: View {
    let serialNumber: String?
    let timestamp: TimeInterval
    let accountId: Int?
    let onRegister: () -> Void
    let onDeregister: () -> Void
    let onAccount: () -> Void
    let onTransfer: () -> Void
    let onNetwork: () -> Void
    let onSettings: () -> Void

    private var isRegistered: Bool {
        serialNumber != nil
    }
    
    private var formattedDate: String {
        guard timestamp > 0 else { return "---" }
        let date = Date(timeIntervalSince1970: timestamp)
        return DateFormatter.registrationDateFormatter.string(from: date)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                Text("Cloud Crypto")
                    .font(.headline)
                    .padding(.top, 8)
                
                // Serial Number Section
                VStack(spacing: 4) {
                    Text("Serial Number")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(serialNumber ?? "---")
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isRegistered {
                        onRegister()
                    }
                }

                // Account ID Section
                if isRegistered, let accountId = accountId {
                    VStack(spacing: 4) {
                        Text("Account ID")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(accountId)")
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding(.vertical, 8)
                }

                // Date Registered Section
                if isRegistered {
                    VStack(spacing: 4) {
                        Text("Date Registered")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formattedDate)
                            .font(.footnote)
                    }
                    .padding(.bottom, 8)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Action Buttons
                VStack(spacing: 8) {
                    if isRegistered {
                        // DE-REGISTER button commented out
                        // Button(action: onDeregister) {
                        //     Text("DE-REGISTER")
                        //         .font(.caption)
                        //         .fontWeight(.semibold)
                        //         .frame(maxWidth: .infinity)
                        // }
                        // .buttonStyle(.borderedProminent)
                        // .tint(.red)
                        
                        Button(action: onAccount) {
                            Text("ACCOUNT")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: onTransfer) {
                            Text("TRANSFER")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: onNetwork) {
                            Text("NETWORK")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        // SETTINGS button commented out - will implement later
                        // Button(action: onSettings) {
                        //     Text("SETTINGS")
                        //         .font(.caption)
                        //         .fontWeight(.semibold)
                        //         .frame(maxWidth: .infinity)
                        // }
                        // .buttonStyle(.bordered)
                    } else {
                        Button(action: onRegister) {
                            Text("REGISTER")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding()
        }
    }
}

#Preview {
    MainScreenView(
        serialNumber: "ABC-123-DEF-456",
        timestamp: Date().timeIntervalSince1970,
        accountId: 42,
        onRegister: {},
        onDeregister: {},
        onAccount: {},
        onTransfer: {},
        onNetwork: {},
        onSettings: {}
    )
}
