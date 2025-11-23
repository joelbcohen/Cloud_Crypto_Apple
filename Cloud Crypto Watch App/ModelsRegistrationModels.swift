//
//  RegistrationModels.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

// MARK: - Registration Request

struct RegistrationRequest: Codable {
    let serialNumber: String
    let id: String  // Device identifier
    let fcmToken: String?  // APNs token for watchOS
    let apnsEnvironment: String?  // "sandbox" or "production"
    let deviceType: String  // Hard-coded as "ios"
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

// MARK: - Registration Response

struct RegistrationResponse: Codable {
    let status: String?
    let message: String?
    let registrationId: String?
    let publicKey: String?
    let accountId: Int?
    let reward: Int?
    let isNewAccount: Bool?
    let remainingBalance: Double?
}

// MARK: - Deregistration Request

struct DeregistrationRequest: Codable {
    let publicKey: String
    let attestationBlob: String
    let serialNumber: String
}

// MARK: - Deregistration Response

struct DeregistrationResponse: Codable {
    let status: String?
    let message: String?
}
