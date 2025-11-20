//
//  AccountSummaryView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct AccountSummaryView: View {
    let data: AccountSummaryData
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Account Summary")
                    .font(.headline)
                    .padding(.top, 8)
                
                // Current Balance
                VStack(spacing: 4) {
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(data.balance?.formattedAsCurrency() ?? "0.00")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Transaction Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transaction Stats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Total Sent
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Sent")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(data.totalSentTransactions) txns")
                            .font(.caption)
                        
                        Text(data.totalSentAmount?.formattedAsCurrency() ?? "0.00")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    // Total Received
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Received")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(data.totalReceivedTransactions) txns")
                            .font(.caption)
                        
                        Text(data.totalReceivedAmount?.formattedAsCurrency() ?? "0.00")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                
                Divider()
                
                // Device Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device Info")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let brand = data.brand, let model = data.model {
                        Text("\(brand) \(model)")
                            .font(.caption)
                    }
                    
                    if let id = data.id {
                        HStack(spacing: 2) {
                            Text("ID:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(String(id))
                                .font(.system(.caption2, design: .monospaced))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                
                // Back Button
                Button(action: onBack) {
                    Text("BACK")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    AccountSummaryView(
        data: AccountSummaryData(
            id: 28,
            balance: "12345.67",
            serialNumber: "TEST-123",
            serialHash: "hash123",
            model: "Apple Watch Series 9",
            brand: "Apple",
            osVersion: "10.0",
            nodeId: "node1",
            totalSentTransactions: 5,
            totalReceivedTransactions: 3,
            totalSentAmount: "1234.56",
            totalReceivedAmount: "11111.11",
            accountCreatedAt: "2025-11-20",
            lastActivity: "2025-11-20"
        ),
        onBack: {}
    )
}
