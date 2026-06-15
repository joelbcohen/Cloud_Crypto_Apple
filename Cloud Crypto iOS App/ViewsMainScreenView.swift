//
//  MainScreenView.swift
//  Cloud Crypto iOS App
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

    private var isRegistered: Bool { serialNumber != nil }

    private var formattedDate: String {
        guard timestamp > 0 else { return "---" }
        let date = Date(timeIntervalSince1970: timestamp)
        return DateFormatter.registrationDateFormatter.string(from: date)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusCard

                if isRegistered {
                    HStack(spacing: 12) {
                        actionButton(title: "ACCOUNT", systemImage: "person.crop.circle", action: onAccount)
                        actionButton(title: "TRANSFER", systemImage: "arrow.up.right", action: onTransfer)
                    }
                    actionButton(
                        title: "NETWORK",
                        systemImage: "network",
                        wide: true,
                        action: onNetwork
                    )
                } else {
                    primaryButton(title: "REGISTER", action: onRegister)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    private var statusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isRegistered ? "checkmark.seal.fill" : "lock.open.fill")
                    .foregroundColor(isRegistered ? AppColors.primary : AppColors.statMints)
                Text(isRegistered ? "Registered" : "Not Registered")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.onSurface)
                Spacer()
            }

            Divider().background(AppColors.onSurfaceMuted.opacity(0.3))

            infoRow(label: "Serial Number", value: serialNumber ?? "---", mono: true)

            if isRegistered, let accountId = accountId {
                infoRow(label: "Account ID", value: "\(accountId)", mono: true)
            }

            if isRegistered {
                infoRow(label: "Date Registered", value: formattedDate, mono: false)
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

    private func infoRow(label: String, value: String, mono: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.onSurfaceMuted)
                .textCase(.uppercase)
            Text(value)
                .font(mono ? .system(.body, design: .monospaced) : .body)
                .foregroundColor(AppColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func actionButton(title: String, systemImage: String, wide: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(AppColors.onSurface)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(AppColors.surface.opacity(0.75))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.primary.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(14)
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(AppColors.primary)
                .cornerRadius(14)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            CryptoBackground()
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
        .navigationTitle("Cloud Crypto")
    }
    .preferredColorScheme(.dark)
}
