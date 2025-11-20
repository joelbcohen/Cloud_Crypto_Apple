//
//  AttestationService.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation
import Security

/// Service for device attestation and key generation
actor AttestationService {
    
    enum AttestationError: Error {
        case keyGenerationFailed
        case keyExportFailed
        case noPublicKey
    }
    
    private let keychainService = KeychainService()
    private let keyTag = "com.cloudcrypto.watch.keypair"
    
    // MARK: - Key Generation
    
    /// Generates RSA 2048-bit key pair and stores in Keychain
    func generateKeyPair() async throws -> (publicKey: String, privateKey: String) {
        // Key attributes
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
        
        // Export public key as Base64
        let publicKeyString = try exportPublicKey(publicKey)
        
        // Export private key (for storage reference)
        let privateKeyString = try exportPrivateKey(privateKey)
        
        return (publicKeyString, privateKeyString)
    }
    
    // MARK: - Key Export
    
    private func exportPublicKey(_ publicKey: SecKey) throws -> String {
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Error exporting public key: \(error.debugDescription)")
            throw AttestationError.keyExportFailed
        }
        
        return publicKeyData.base64EncodedString()
    }
    
    private func exportPrivateKey(_ privateKey: SecKey) throws -> String {
        // For private key, we'll just reference it by tag
        // In a real implementation, you might want to export it differently
        // For now, return the tag as Base64
        let tagData = keyTag.data(using: .utf8)!
        return tagData.base64EncodedString()
    }
    
    // MARK: - Attestation
    
    /// Generates attestation blob (public key as Base64)
    func generateAttestationBlob(publicKey: String) -> String {
        // In a real implementation, this would include additional attestation data
        // For now, we'll use the public key itself
        return publicKey
    }
    
    // MARK: - Key Retrieval
    
    /// Retrieves existing key pair from Keychain
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
    
    // MARK: - Key Deletion
    
    func deleteKeyPair() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
