//
//  NetworkStatusView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 12/10/25.
//

import SwiftUI

struct NetworkStatusView: View {
    let ledgerStats: LedgerStats
    let iosCount: Int
    let androidCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Network Status")
                    .font(.headline)
                    .padding(.top, 8)

                Divider()

                // Ledger Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ledger Statistics")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Total Accounts
                    HStack {
                        Text("Total Accounts:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(ledgerStats.totalAccounts)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Total Transactions
                    HStack {
                        Text("Total Transactions:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(ledgerStats.totalTransactions)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Total Mints
                    HStack {
                        Text("Total Mints:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(ledgerStats.totalMints)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Total Transfers
                    HStack {
                        Text("Total Transfers:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(ledgerStats.totalTransfers)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Total Minted Amount
                    HStack {
                        Text("Total Minted:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(ledgerStats.totalMinted.formattedAsCurrency() ?? "0.00")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

                Divider()

                // Device Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Device Statistics")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // iOS Devices
                    HStack {
                        Text("iOS Devices:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(iosCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Android Devices
                    HStack {
                        Text("Android Devices:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(androidCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }

                    // Total Devices
                    HStack {
                        Text("Total Devices:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(iosCount + androidCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
            .padding()
        }
        .navigationTitle("Network")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NetworkStatusView(
        ledgerStats: LedgerStats(
            totalAccounts: 100,
            totalTransactions: 500,
            totalMints: 250,
            totalTransfers: 250,
            totalMinted: "1000000.00"
        ),
        iosCount: 75,
        androidCount: 25
    )
}
