//
//  AccountModels.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

// MARK: - Account Summary Request

struct AccountSummaryRequest: Codable {
    let serialNumber: String
    let publicKey: String
    let attestationBlob: String
}

// MARK: - Account Summary Response

struct AccountSummaryResponse: Codable {
    let status: String?
    let message: String?
    let account: AccountSummaryData?
    let transactions: [Transaction]?
}

// MARK: - Transaction

struct Transaction: Codable, Identifiable, Equatable {
    let id: Int
    let txHash: String?
    let txType: String?
    let amount: String?
    let status: String?
    let memo: String?
    let createdAt: String?
    let completedAt: String?
    let fromId: Int?
    let toId: Int?
    let direction: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case txHash = "tx_hash"
        case txType = "tx_type"
        case amount, status, memo
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case fromId = "from_id"
        case toId = "to_id"
        case direction
    }
    
    var completedDate: String? {
        guard let completedAt = completedAt else { return nil }
        // Parse "2025-11-23 06:54:50" format
        let components = completedAt.split(separator: " ")
        return components.first.map(String.init)
    }
    
    var completedTime: String? {
        guard let completedAt = completedAt else { return nil }
        // Parse "2025-11-23 06:54:50" format
        let components = completedAt.split(separator: " ")
        return components.count > 1 ? String(components[1]) : nil
    }
    
    var formattedCompletedAt: String? {
        guard let completedAt = completedAt else { return nil }
        
        // Create date formatter to parse the input
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: completedAt) else { return nil }
        
        // Create date formatter for output: "Nov 25 2025 1:34 PM"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d yyyy h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
}

// MARK: - Account Summary Data

struct AccountSummaryData: Codable, Equatable {
    let id: Int?
    let balance: String?
    let serialNumber: String?
    let serialHash: String?
    let model: String?
    let brand: String?
    let osVersion: String?
    let nodeId: String?
    let totalSentTransactions: Int
    let totalReceivedTransactions: Int
    let totalSentAmount: String?
    let totalReceivedAmount: String?
    let accountCreatedAt: String?
    let lastActivity: String?
    
    enum CodingKeys: String, CodingKey {
        case id, balance
        case serialNumber = "serial_number"
        case serialHash = "serial_hash"
        case model, brand
        case osVersion = "os_version"
        case nodeId = "node_id"
        case totalSentTransactions = "total_sent_transactions"
        case totalReceivedTransactions = "total_received_transactions"
        case totalSentAmount = "total_sent_amount"
        case totalReceivedAmount = "total_received_amount"
        case accountCreatedAt = "account_created_at"
        case lastActivity = "last_activity"
    }
}

// MARK: - Transfer Request

struct TransferRequest: Codable {
    let serialNumber: String
    let publicKey: String
    let attestationBlob: String
    let toAccountId: String
    let amount: String
    let memo: String?
}

// MARK: - Transfer Response

struct TransferResponse: Codable {
    let status: String?
    let message: String?
    let transactionId: Int?
    let fromAccountId: Int?
    let toAccountId: Int?
    let amount: String?
    let fcmNotificationSent: Bool?
    let newBalance: String?
}

// MARK: - Network Status Response

struct NetworkStatusResponse: Codable {
    let status: String?
    let message: String?
    let ledgerStats: LedgerStats?
    let deviceStats: DeviceStats?

    enum CodingKeys: String, CodingKey {
        case status, message
        case ledgerStats = "ledger_stats"
        case deviceStats = "device_stats"
    }
}

// MARK: - Ledger Stats

struct LedgerStats: Codable, Equatable {
    let totalAccounts: Int
    let totalTransactions: Int
    let totalMints: Int
    let totalTransfers: Int
    let totalMinted: String

    enum CodingKeys: String, CodingKey {
        case totalAccounts = "total_accounts"
        case totalTransactions = "total_transactions"
        case totalMints = "total_mints"
        case totalTransfers = "total_transfers"
        case totalMinted = "total_minted"
    }
}

// MARK: - Device Stats

struct DeviceStats: Codable, Equatable {
    let ios: DevicePlatformStats?
    let android: DevicePlatformStats?
}

// MARK: - Device Platform Stats

struct DevicePlatformStats: Codable, Equatable {
    let count: Int
}
