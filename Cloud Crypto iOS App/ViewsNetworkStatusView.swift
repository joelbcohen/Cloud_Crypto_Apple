//
//  NetworkStatusView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

struct NetworkStatusView: View {
    let ledgerStats: LedgerStats
    let iosCount: Int
    let androidCount: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusPill

                ledgerCard

                deviceCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Network Status")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppColors.success)
                .frame(width: 10, height: 10)
            Text("Online")
                .font(.headline.weight(.semibold))
                .foregroundColor(AppColors.success)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.success.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.success.opacity(0.4), lineWidth: 1)
        )
    }

    private var ledgerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LEDGER STATISTICS")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .tracking(1)

            statRow(label: "Accounts", value: ledgerStats.totalAccounts ?? 0, color: AppColors.statAccounts)
            statRow(label: "Transactions", value: ledgerStats.totalTransactions ?? 0, color: AppColors.statTransactions)
            statRow(label: "Mints", value: ledgerStats.totalMints ?? 0, color: AppColors.statMints)
            statRow(label: "Transfers", value: ledgerStats.totalTransfers ?? 0, color: AppColors.statTransfers)
            statRow(label: "Minted", value: ledgerStats.totalMinted ?? 0, color: AppColors.statMinted)
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

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DEVICE STATISTICS")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .tracking(1)

            HStack(spacing: 12) {
                deviceTile(title: "Apple", count: iosCount, color: AppColors.deviceApple, icon: "applelogo")
                deviceTile(title: "Google", count: androidCount, color: AppColors.deviceGoogle, icon: "g.circle.fill")
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

    private func statRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.onSurface)
            Spacer()
            Text(value.formatAsInteger())
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
        }
    }

    private func deviceTile(title: String, count: Int, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
            Text("\(count)")
                .font(.title.weight(.bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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
            NetworkStatusView(
                ledgerStats: LedgerStats(
                    totalAccounts: 57,
                    totalTransactions: 824,
                    totalMints: 750,
                    totalTransfers: 74,
                    totalMinted: 4_324_856
                ),
                iosCount: 8,
                androidCount: 11
            )
        }
    }
    .preferredColorScheme(.dark)
}
