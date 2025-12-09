//
//  AccountSummaryView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct AccountSummaryView: View {
    let data: AccountSummaryData
    let transactions: [Transaction]
    let onBack: () -> Void
    
    @State private var showTransactions = false
    
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
                
                Divider()
                
                // Transactions Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Transactions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    // Show/Hide History Button
                    if !transactions.isEmpty {
                        Button(action: {
                            withAnimation {
                                showTransactions.toggle()
                            }
                        }) {
                            Text(showTransactions ? "HIDE HISTORY" : "SHOW HISTORY")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if transactions.isEmpty {
                        Text("No transactions yet")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else if showTransactions {
                        ForEach(transactions) { transaction in
                            VStack(alignment: .leading, spacing: 4) {
                                // Transaction Type and Amount
                                HStack {
                                    Text(transaction.txType?.capitalized ?? "Unknown")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(transaction.amount?.formattedAsCurrency() ?? "0.00")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(transaction.direction == "sent" ? .red : .green)
                                }
                                
                                // From/To IDs
                                HStack(spacing: 4) {
                                    Text("From:")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(transaction.fromId ?? 0)")
                                        .font(.system(.caption2, design: .monospaced))
                                    
                                    Text("→")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("To:")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(transaction.toId ?? 0)")
                                        .font(.system(.caption2, design: .monospaced))
                                }
                                
                                // Memo
                                if let memo = transaction.memo, !memo.isEmpty {
                                    HStack(spacing: 4) {
                                        Text("Memo:")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(memo)
                                            .font(.caption2)
                                            .lineLimit(2)
                                    }
                                }
                                
                                // Completed Date and Time
                                if let formattedDate = transaction.formattedCompletedAt {
                                    HStack(spacing: 4) {
                                        Text("Completed:")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(formattedDate)
                                            .font(.caption2)
                                    }
                                }
                                
                                Divider()
                                    .padding(.top, 4)
                            }
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
        transactions: [
            Transaction(
                id: 1,
                txHash: "0xabc123",
                txType: "transfer",
                amount: "42.00",
                status: "completed",
                memo: "Test transfer",
                createdAt: "2025-11-23 06:54:50",
                completedAt: "2025-11-23 06:54:50",
                fromId: 24,
                toId: 42,
                direction: "sent"
            ),
            Transaction(
                id: 2,
                txHash: "0xdef456",
                txType: "transfer",
                amount: "100.00",
                status: "completed",
                memo: "Received",
                createdAt: "2025-11-22 12:30:00",
                completedAt: "2025-11-22 12:30:00",
                fromId: 42,
                toId: 24,
                direction: "received"
            )
        ],
        onBack: {}
    )
}
