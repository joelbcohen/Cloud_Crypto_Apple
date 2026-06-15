//
//  RegistrationModels.swift
//  Cloud Crypto iOS App
//

import Foundation

nonisolated struct RegistrationRequest: Codable {
    let serialNumber: String
    let id: String           // Device identifier
    let fcmToken: String?    // APNs token; backend names this field fcmToken across platforms
    let apnsEnvironment: String?
    let deviceType: String   // "ios"
    let publicKey: String?
    let attestationBlob: String?
    let deviceModel: String?
    let deviceBrand: String?
    let osVersion: String?
    let nodeId: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case serialNumber, id, fcmToken, apnsEnvironment, deviceType, publicKey, attestationBlob
        case deviceModel, deviceBrand, osVersion, nodeId, latitude, longitude
    }
}

nonisolated struct RegistrationResponse: Codable {
    let status: String?
    let message: String?
    let registrationId: String?
    let publicKey: String?
    let accountId: Int?
    let reward: Int?
    let isNewAccount: Bool?
    let remainingBalance: Double?
}

nonisolated struct DeregistrationRequest: Codable {
    let publicKey: String
    let attestationBlob: String
    let serialNumber: String
}

nonisolated struct DeregistrationResponse: Codable {
    let status: String?
    let message: String?
}
