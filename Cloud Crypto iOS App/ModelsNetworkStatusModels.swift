//
//  NetworkStatusModels.swift
//  Cloud Crypto iOS App
//

import Foundation

nonisolated struct NetworkStatusResponse: Codable {
    let status: String?
    let blockchainVersion: String?
    let ledgerStats: LedgerStats?
    let deviceStats: DeviceStats?

    enum CodingKeys: String, CodingKey {
        case status
        case blockchainVersion = "Blockchain Version"
        case ledgerStats = "ledger_stats"
        case deviceStats = "device_stats"
    }
}

nonisolated struct LedgerStats: Codable, Equatable {
    let totalAccounts: Int?
    let totalTransactions: Int?
    let totalMints: Int?
    let totalTransfers: Int?
    let totalMinted: Int?

    enum CodingKeys: String, CodingKey {
        case totalAccounts = "total_accounts"
        case totalTransactions = "total_transactions"
        case totalMints = "total_mints"
        case totalTransfers = "total_transfers"
        case totalMinted = "total_minted"
    }
}

nonisolated struct DeviceStats: Codable, Equatable {
    let ios: DeviceCount?
    let android: DeviceCount?
}

nonisolated struct DeviceCount: Codable, Equatable {
    let count: Int?
}
