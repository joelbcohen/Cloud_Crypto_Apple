//
//  AttestationService.swift
//  Cloud Crypto iOS App
//

import Foundation
import Security

actor AttestationService {

    enum AttestationError: Error {
        case keyGenerationFailed
        case keyExportFailed
        case noPublicKey
    }

    private let keyTag = "com.cloudcrypto.ios.keypair"

    func generateKeyPair() async throws -> (publicKey: String, privateKey: String) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Error generating key pair: \(error.debugDescription)")
            throw AttestationError.keyGenerationFailed
        }

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw AttestationError.noPublicKey
        }

        let publicKeyString = try exportPublicKey(publicKey)
        let privateKeyString = try exportPrivateKey(privateKey)
        return (publicKeyString, privateKeyString)
    }

    private func exportPublicKey(_ publicKey: SecKey) throws -> String {
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Error exporting public key: \(error.debugDescription)")
            throw AttestationError.keyExportFailed
        }
        return publicKeyData.base64EncodedString()
    }

    private func exportPrivateKey(_ privateKey: SecKey) throws -> String {
        let tagData = keyTag.data(using: .utf8)!
        return tagData.base64EncodedString()
    }

    func generateAttestationBlob(publicKey: String) -> String {
        return publicKey
    }

    func getExistingKeyPair() async throws -> (publicKey: String, privateKey: String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let privateKey = item as! SecKey? else {
            return nil
        }

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return nil
        }

        let publicKeyString = try exportPublicKey(publicKey)
        let privateKeyString = try exportPrivateKey(privateKey)
        return (publicKeyString, privateKeyString)
    }

    func deleteKeyPair() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!
        ]
        SecItemDelete(query as CFDictionary)
    }
}
