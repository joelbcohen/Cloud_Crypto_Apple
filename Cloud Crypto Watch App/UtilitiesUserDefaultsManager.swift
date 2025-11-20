//
//  UserDefaultsManager.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

/// Manager for UserDefaults persistence operations
@MainActor
class UserDefaultsManager {
    
    // MARK: - Keys
    
    private enum Keys {
        static let isRegistered = "is_registered"
        static let serialNumber = "serial_number"
        static let registrationTimestamp = "registration_timestamp"
        static let publicKey = "public_key"
        static let privateKey = "private_key"
    }
    
    private let defaults: UserDefaults
    
    // MARK: - Initialization
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Registration Status
    
    func saveRegistrationStatus(_ status: RegistrationStatus) {
        defaults.set(status.isRegistered, forKey: Keys.isRegistered)
        defaults.set(status.serialNumber, forKey: Keys.serialNumber)
        defaults.set(status.registrationTimestamp, forKey: Keys.registrationTimestamp)
        defaults.set(status.publicKey, forKey: Keys.publicKey)
        defaults.set(status.privateKey, forKey: Keys.privateKey)
    }
    
    func loadRegistrationStatus() -> RegistrationStatus {
        let isRegistered = defaults.bool(forKey: Keys.isRegistered)
        let serialNumber = defaults.string(forKey: Keys.serialNumber)
        let timestamp = defaults.double(forKey: Keys.registrationTimestamp)
        let publicKey = defaults.string(forKey: Keys.publicKey)
        let privateKey = defaults.string(forKey: Keys.privateKey)
        
        return RegistrationStatus(
            isRegistered: isRegistered,
            serialNumber: serialNumber,
            registrationTimestamp: timestamp,
            publicKey: publicKey,
            privateKey: privateKey
        )
    }
    
    func clearRegistrationData() {
        defaults.removeObject(forKey: Keys.isRegistered)
        defaults.removeObject(forKey: Keys.serialNumber)
        defaults.removeObject(forKey: Keys.registrationTimestamp)
        defaults.removeObject(forKey: Keys.publicKey)
        defaults.removeObject(forKey: Keys.privateKey)
    }
}
