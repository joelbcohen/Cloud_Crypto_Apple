//
//  RegistrationStatus.swift
//  Cloud Crypto iOS App
//

import Foundation

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
