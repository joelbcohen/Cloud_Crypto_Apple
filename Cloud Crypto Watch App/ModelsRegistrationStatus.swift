//
//  RegistrationStatus.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

/// Local registration status model
struct RegistrationStatus {
    let isRegistered: Bool
    let serialNumber: String?
    let registrationTimestamp: TimeInterval
    let publicKey: String?
    let privateKey: String?
    let accountId: Int?

    static var empty: RegistrationStatus {
        RegistrationStatus(
            isRegistered: false,
            serialNumber: nil,
            registrationTimestamp: 0,
            publicKey: nil,
            privateKey: nil,
            accountId: nil
        )
    }
}
