//
//  NetworkStatusView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/26/25.
//

import SwiftUI

struct NetworkStatusView: View {
    let ledgerStats: LedgerStats
    let iosCount: Int
    let androidCount: Int
    let onBack: () -> Void

    @State private var dragOffset: CGFloat = 0

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
                    
                    // Accounts
                    HStack {
                        Text("Accounts")
                            .font(.caption)
                        Spacer()
                        Text("\(ledgerStats.totalAccounts ?? 0)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Transactions
                    HStack {
                        Text("Transactions")
                            .font(.caption)
                        Spacer()
                        Text("\(ledgerStats.totalTransactions ?? 0)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Mints
                    HStack {
                        Text("Mints")
                            .font(.caption)
                        Spacer()
                        Text("\(ledgerStats.totalMints ?? 0)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    // Transfers
                    HStack {
                        Text("Transfers")
                            .font(.caption)
                        Spacer()
                        Text("\(ledgerStats.totalTransfers ?? 0)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    // Minted
                    HStack {
                        Text("Minted")
                            .font(.caption)
                        Spacer()
                        Text("\(ledgerStats.totalMinted?.formattedAsNumber() ?? "0")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
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
                    
                    // Apple Watch
                    HStack {
                        Text("Apple Watch")
                            .font(.caption)
                        Spacer()
                        Text("\(iosCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Google Watch
                    HStack {
                        Text("Google Watch")
                            .font(.caption)
                        Spacer()
                        Text("\(androidCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
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
                    // Trigger back if swipe distance > 50 or velocity is high enough
                    if gesture.translation.width > 50 || gesture.predictedEndTranslation.width > 100 {
                        onBack()
                    }
                    // Reset offset
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = 0
                    }
                }
        )
    }
}

// MARK: - Number Formatting Extension

extension Int {
    func formattedAsNumber() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    NetworkStatusView(
        ledgerStats: LedgerStats(
            totalAccounts: 57,
            totalTransactions: 824,
            totalMints: 750,
            totalTransfers: 74,
            totalMinted: 4324856
        ),
        iosCount: 8,
        androidCount: 11,
        onBack: {}
    )
}
