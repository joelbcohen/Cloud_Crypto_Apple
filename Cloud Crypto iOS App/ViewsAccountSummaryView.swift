//
//  AccountSummaryView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct AccountSummaryView: View {
    let data: AccountSummaryData
    let transactions: [Transaction]

    @State private var showTransactions = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                balanceCard
                statsCard
                deviceCard
                transactionsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Account Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Balance

    private var balanceCard: some View {
        VStack(spacing: 6) {
            Text("CURRENT BALANCE")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .tracking(1)

            Text(data.balance?.formattedAsCurrency() ?? "0.00")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.surface.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.primary.opacity(0.35), lineWidth: 1)
        )
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRANSACTION STATS")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .tracking(1)

            HStack(spacing: 12) {
                statBox(
                    title: "Total Sent",
                    count: data.totalSentTransactions,
                    amount: data.totalSentAmount?.formattedAsCurrency() ?? "0.00",
                    color: AppColors.sent
                )
                statBox(
                    title: "Total Received",
                    count: data.totalReceivedTransactions,
                    amount: data.totalReceivedAmount?.formattedAsCurrency() ?? "0.00",
                    color: AppColors.received
                )
            }
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

    private func statBox(title: String, count: Int, amount: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
            Text("\(count) txns")
                .font(.caption)
                .foregroundColor(AppColors.onSurface)
            Text(amount)
                .font(.headline.weight(.bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.background.opacity(0.4))
        )
    }

    // MARK: - Device

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEVICE INFO")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .tracking(1)

            if let brand = data.brand, let model = data.model {
                rowItem(label: "Device", value: "\(brand) \(model)")
            }
            if let id = data.id {
                rowItem(label: "Account ID", value: "\(id)", mono: true)
            }
            if let serial = data.serialNumber {
                rowItem(label: "Serial", value: serial, mono: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func rowItem(label: String, value: String, mono: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.onSurfaceMuted)
            Spacer()
            Text(value)
                .font(mono ? .system(.subheadline, design: .monospaced) : .subheadline)
                .foregroundColor(AppColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    // MARK: - Transactions

    private var transactionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TRANSACTIONS")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.onSurfaceMuted)
                    .tracking(1)
                Spacer()
                Text("\(transactions.count)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(AppColors.primary)
            }

            if transactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundColor(AppColors.onSurfaceMuted)
                    .padding(.vertical, 12)
            } else {
                Button(action: { withAnimation { showTransactions.toggle() } }) {
                    Text(showTransactions ? "HIDE HISTORY" : "SHOW HISTORY")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.secondary.opacity(0.55), lineWidth: 1)
                        )
                }

                if showTransactions {
                    VStack(spacing: 10) {
                        ForEach(transactions) { transaction in
                            transactionRow(transaction)
                        }
                    }
                }
            }
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

    private func transactionRow(_ transaction: Transaction) -> some View {
        let isSent = transaction.direction == "sent"
        let isMint = (transaction.txType ?? "").lowercased() == "mint"
        let amountColor: Color = isMint ? AppColors.statMints : (isSent ? AppColors.sent : AppColors.received)
        let icon: String = isMint ? "sparkles" : (isSent ? "arrow.up.right" : "arrow.down.left")

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(amountColor)
                    Text((transaction.txType ?? "Unknown").uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(amountColor)
                }
                Spacer()
                Text(transaction.amount?.formattedAsCurrency() ?? "0.00")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(amountColor)
            }

            HStack(spacing: 6) {
                Text("From:")
                    .font(.caption2)
                    .foregroundColor(AppColors.onSurfaceMuted)
                Text("\(transaction.fromId ?? 0)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(AppColors.onSurface)
                Text("→")
                    .font(.caption2)
                    .foregroundColor(AppColors.onSurfaceMuted)
                Text("To:")
                    .font(.caption2)
                    .foregroundColor(AppColors.onSurfaceMuted)
                Text("\(transaction.toId ?? 0)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(AppColors.onSurface)
            }

            if let memo = transaction.memo, !memo.isEmpty {
                Text("“\(memo)”")
                    .font(.caption2)
                    .foregroundColor(AppColors.onSurfaceMuted)
                    .italic()
                    .lineLimit(2)
            }

            if let formattedDate = transaction.formattedCompletedAt {
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(AppColors.onSurfaceMuted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.background.opacity(0.4))
        )
    }
}

#Preview {
    NavigationStack {
        ZStack {
            CryptoBackground()
            AccountSummaryView(
                data: AccountSummaryData(
                    id: 28,
                    balance: "12345.67",
                    serialNumber: "TEST-123",
                    serialHash: "hash123",
                    model: "iPhone 15 Pro",
                    brand: "Apple",
                    osVersion: "18.0",
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
                    )
                ]
            )
        }
    }
    .preferredColorScheme(.dark)
}
