//
//  RegistrationRepository.swift
//  Cloud Crypto iOS App
//

import Foundation

@MainActor
class RegistrationRepository {

    private let networkService = NetworkService()
    private let deviceInfoService = DeviceInfoService()
    private let attestationService = AttestationService()
    private let userDefaultsManager = UserDefaultsManager()

    func loadRegistrationStatus() -> RegistrationStatus {
        return userDefaultsManager.loadRegistrationStatus()
    }

    func saveRegistrationStatus(_ status: RegistrationStatus) {
        userDefaultsManager.saveRegistrationStatus(status)
    }

    func clearRegistrationData() {
        userDefaultsManager.clearRegistrationData()
    }

    func registerDevice(serialNumber: String, apnsToken: String?, apnsEnvironment: String?) async throws -> RegistrationResponse {
        let keyPair = try await attestationService.generateKeyPair()
        let deviceInfo = await deviceInfoService.collectDeviceInfo()
        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: keyPair.publicKey)

        let request = RegistrationRequest(
            serialNumber: serialNumber,
            id: deviceInfo.id,
            fcmToken: apnsToken,
            apnsEnvironment: apnsEnvironment,
            deviceType: "ios",
            publicKey: keyPair.publicKey,
            attestationBlob: attestationBlob,
            deviceModel: deviceInfo.model,
            deviceBrand: deviceInfo.brand,
            osVersion: deviceInfo.osVersion,
            nodeId: nil,
            latitude: nil,
            longitude: nil
        )

        let response = try await networkService.registerDevice(request)

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
        clearRegistrationData()
        try await attestationService.deleteKeyPair()
        return response
    }

    func getAccountSummary() async throws -> AccountSummaryResponse {
        let status = loadRegistrationStatus()

        guard let serialNumber = status.serialNumber,
              let publicKey = status.publicKey else {
            throw RepositoryError.notRegistered
        }

        let attestationBlob = await attestationService.generateAttestationBlob(publicKey: publicKey)

        let request = AccountSummaryRequest(
            serialNumber: serialNumber,
            publicKey: publicKey,
            attestationBlob: attestationBlob
        )

        return try await networkService.getAccountSummary(request)
    }

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

    func getNetworkStatus() async throws -> NetworkStatusResponse {
        return try await networkService.getNetworkStatus()
    }

    func generateSerialNumber() async -> String {
        return await deviceInfoService.generateSerialNumber()
    }
}

enum RepositoryError: Error, LocalizedError {
    case notRegistered

    var errorDescription: String? {
        switch self {
        case .notRegistered:
            return "Device is not registered"
        }
    }
}
