//
//  RegistrationRepository.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

/// Repository layer for managing registration data and business logic
@MainActor
class RegistrationRepository {
    
    private let networkService = NetworkService()
    private let deviceInfoService = DeviceInfoService()
    private let attestationService = AttestationService()
    private let userDefaultsManager = UserDefaultsManager()
    
    // MARK: - Registration Status
    
    func loadRegistrationStatus() -> RegistrationStatus {
        return userDefaultsManager.loadRegistrationStatus()
    }
    
    func saveRegistrationStatus(_ status: RegistrationStatus) {
        userDefaultsManager.saveRegistrationStatus(status)
    }
    
    func clearRegistrationData() {
        userDefaultsManager.clearRegistrationData()
    }
    
    // MARK: - Registration
    
    func registerDevice(serialNumber: String, apnsToken: String?, apnsEnvironment: String?) async throws -> RegistrationResponse {
        print("🔧 [Repository] registerDevice called")
        print("🔧 [Repository] serialNumber: \(serialNumber)")
        print("🔧 [Repository] apnsToken: \(apnsToken ?? "❌ NIL")")
        print("🔧 [Repository] apnsEnvironment: \(apnsEnvironment ?? "❌ NIL")")
        
        // Generate key pair
        let keyPair = try await attestationService.generateKeyPair()
        
        // Collect device info
        let deviceInfo = await deviceInfoService.collectDeviceInfo()
        
        // Generate attestation blob
        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: keyPair.publicKey)
        
        // Create registration request
        let request = RegistrationRequest(
            serialNumber: serialNumber,
            id: deviceInfo.id,
            fcmToken: apnsToken,
            apnsEnvironment: apnsEnvironment,
            deviceType: "ios",  // Hard-coded as "ios"
            publicKey: keyPair.publicKey,
            attestationBlob: attestationBlob,
            deviceModel: deviceInfo.model,
            deviceBrand: deviceInfo.brand,
            osVersion: deviceInfo.osVersion,
            nodeId: nil,
            latitude: nil,
            longitude: nil
        )
        
        print("🔧 [Repository] Created RegistrationRequest:")
        print("🔧 [Repository]   - fcmToken: \(request.fcmToken ?? "❌ NIL")")
        print("🔧 [Repository]   - apnsEnvironment: \(request.apnsEnvironment ?? "❌ NIL")")
        print("🔧 [Repository]   - serialNumber: \(request.serialNumber)")
        print("🔧 [Repository]   - id: \(request.id)")
        
        // Send registration request
        let response = try await networkService.registerDevice(request)

        // Save registration status
        let status = RegistrationStatus(
            isRegistered: true,
            serialNumber: serialNumber,
            registrationTimestamp: Date().timeIntervalSince1970,
            publicKey: keyPair.publicKey,
            privateKey: keyPair.privateKey,
            accountId: response.accountId
        )
        saveRegistrationStatus(status)

        return response
    }
    
    // MARK: - Deregistration
    
    func deregisterDevice() async throws -> DeregistrationResponse {
        let status = loadRegistrationStatus()
        
        guard let serialNumber = status.serialNumber,
              let publicKey = status.publicKey else {
            throw RepositoryError.notRegistered
        }
        
        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: publicKey)
        
        let request = DeregistrationRequest(
            publicKey: publicKey,
            attestationBlob: attestationBlob,
            serialNumber: serialNumber
        )
        
        let response = try await networkService.deregisterDevice(request)
        
        // Clear local data
        clearRegistrationData()
        
        // Delete key pair
        try await attestationService.deleteKeyPair()
        
        return response
    }
    
    // MARK: - Account Summary
    
    func getAccountSummary() async throws -> AccountSummaryResponse {
        print("📊 Fetching account summary...")
        
        let status = loadRegistrationStatus()
        
        guard let serialNumber = status.serialNumber,
              let publicKey = status.publicKey else {
            print("❌ Account summary failed: Not registered")
            throw RepositoryError.notRegistered
        }
        
        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: publicKey)
        
        print("=== Account Summary Request ===")
        print("Serial Number: \(serialNumber)")
        print("Public Key: \(publicKey.prefix(50))...")
        print("==============================")
        
        let request = AccountSummaryRequest(
            serialNumber: serialNumber,
            publicKey: publicKey,
            attestationBlob: attestationBlob
        )
        
        let response = try await networkService.getAccountSummary(request)
        
        print("✅ Account summary fetched successfully")
        
        return response
    }
    
    // MARK: - Transfer
    
    func executeTransfer(toAccountId: String, amount: String, memo: String?) async throws -> TransferResponse {
        let status = loadRegistrationStatus()
        
        guard let serialNumber = status.serialNumber,
              let publicKey = status.publicKey else {
            throw RepositoryError.notRegistered
        }
        
        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: publicKey)
        
        let request = TransferRequest(
            serialNumber: serialNumber,
            publicKey: publicKey,
            attestationBlob: attestationBlob,
            toAccountId: toAccountId,
            amount: amount,
            memo: memo
        )
        
        return try await networkService.executeTransfer(request)
    }
    
    // MARK: - Network Status
    
    func getNetworkStatus() async throws -> NetworkStatusResponse {
        print("🌐 Fetching network status...")
        
        let response = try await networkService.getNetworkStatus()
        
        print("✅ Network status fetched successfully")
        
        return response
    }
    
    // MARK: - Device Info
    
    func generateSerialNumber() async -> String {
        return await deviceInfoService.generateSerialNumber()
    }
}

// MARK: - Repository Error

enum RepositoryError: Error, LocalizedError {
    case notRegistered
    
    var errorDescription: String? {
        switch self {
        case .notRegistered:
            return "Device is not registered"
        }
    }
}
