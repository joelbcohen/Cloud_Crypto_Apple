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
