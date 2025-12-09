//
//  RegistrationViewModel.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation
import SwiftUI
internal import Combine

/// UI State enum for different screens
enum RegistrationUiState: Equatable {
    case mainScreen(serialNumber: String?, timestamp: TimeInterval, accountId: Int?)
    case registrationForm
    case accountSummary(data: AccountSummaryData, transactions: [Transaction])
    case transferScreen
    case networkStatus(ledgerStats: LedgerStats, iosCount: Int, androidCount: Int)
    case loading
    case error(message: String)
}

/// Main view model for the app
@MainActor
class RegistrationViewModel: ObservableObject {
    
    @Published var uiState: RegistrationUiState = .loading
    @Published var serialNumber: String = ""
    @Published var toastMessage: String?
    @Published var toAccount: String = ""
    @Published var amount: String = ""
    @Published var memo: String = ""
    @Published var isTransferring: Bool = false
    @Published var showDeregisterConfirmation: Bool = false
    
    private let repository = RegistrationRepository()
    private var apnsToken: String?
    private var apnsEnvironment: String?
    
    // MARK: - Initialization
    
    init() {
        print("🟢 [RegistrationViewModel.init] ViewModel initialized, apnsToken is: \(apnsToken ?? "nil")")
        loadMainScreen()
    }
    
    // MARK: - Main Screen
    
    func loadMainScreen() {
        let status = repository.loadRegistrationStatus()

        if status.isRegistered {
            uiState = .mainScreen(
                serialNumber: status.serialNumber,
                timestamp: status.registrationTimestamp,
                accountId: status.accountId
            )
        } else {
            uiState = .mainScreen(serialNumber: nil, timestamp: 0, accountId: nil)
        }
    }
    
    // MARK: - Registration Form
    
    func showRegistrationForm() {
        uiState = .registrationForm
        serialNumber = ""
    }
    
    func onSerialNumberChanged(_ newValue: String) {
        serialNumber = newValue
    }
    
    func registerDevice() {
        guard !serialNumber.isEmpty else {
            toastMessage = "Please enter a serial number"
            return
        }
        
        if apnsToken == nil {
            print("⚠️ WARNING: Registering without APNs token!")
        } else {
            print("📱 Registering with APNs token: \(apnsToken!)")
        }
        
        Task {
            uiState = .loading
            
            do {
                let response = try await repository.registerDevice(
                    serialNumber: serialNumber,
                    apnsToken: apnsToken,
                    apnsEnvironment: apnsEnvironment
                )
                
                print("✅ Registration successful: \(response)")
                
                toastMessage = response.message ?? "Registration successful"
                
                // Return to main screen
                loadMainScreen()
                
            } catch {
                print("❌ Registration failed: \(error)")
                toastMessage = "Registration failed: \(error.localizedDescription)"
                uiState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func generateSerialNumber() {
        Task {
            serialNumber = await repository.generateSerialNumber()
        }
    }
    
    // MARK: - Deregistration
    
    func confirmDeregister() {
        showDeregisterConfirmation = true
    }
    
    func deregisterDevice() {
        showDeregisterConfirmation = false
        
        Task {
            uiState = .loading
            
            do {
                let response = try await repository.deregisterDevice()
                
                print("✅ Deregistration successful: \(response)")
                
                toastMessage = response.message ?? "Deregistration successful"
                
                // Return to main screen
                loadMainScreen()
                
            } catch {
                print("❌ Deregistration failed: \(error)")
                toastMessage = "Deregistration failed: \(error.localizedDescription)"
                loadMainScreen()
            }
        }
    }
    
    // MARK: - Account Screen

    func showAccountScreen() {
        Task {
            uiState = .loading

            do {
                let response = try await repository.getAccountSummary()

                if let accountData = response.account {
                    // Update stored account ID if available and not already saved
                    if let accountId = accountData.id {
                        let currentStatus = repository.loadRegistrationStatus()
                        if currentStatus.accountId != accountId {
                            let updatedStatus = RegistrationStatus(
                                isRegistered: currentStatus.isRegistered,
                                serialNumber: currentStatus.serialNumber,
                                registrationTimestamp: currentStatus.registrationTimestamp,
                                publicKey: currentStatus.publicKey,
                                privateKey: currentStatus.privateKey,
                                accountId: accountId
                            )
                            repository.saveRegistrationStatus(updatedStatus)
                        }
                    }

                    let transactions = response.transactions ?? []
                    uiState = .accountSummary(data: accountData, transactions: transactions)
                } else {
                    throw NSError(
                        domain: "CloudCrypto",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: response.message ?? "No account data"]
                    )
                }

            } catch {
                print("❌ Failed to load account: \(error)")
                toastMessage = "Failed to load account: \(error.localizedDescription)"
                uiState = .error(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Transfer Screen
    
    func showTransferScreen() {
        uiState = .transferScreen
        toAccount = ""
        amount = ""
        memo = ""
    }
    
    func onToAccountChanged(_ newValue: String) {
        toAccount = newValue
    }
    
    func onAmountChanged(_ newValue: String) {
        amount = newValue
    }
    
    func executeTransfer() {
        guard !toAccount.isEmpty else {
            toastMessage = "Please enter destination account"
            return
        }
        
        guard !amount.isEmpty, Double(amount) != nil else {
            toastMessage = "Please enter valid amount"
            return
        }
        
        Task {
            isTransferring = true
            
            do {
                let response = try await repository.executeTransfer(
                    toAccountId: toAccount,
                    amount: amount,
                    memo: memo.isEmpty ? nil : memo
                )
                
                print("✅ Transfer successful: \(response)")
                
                toastMessage = response.message ?? "Transfer successful"
                
                // Return to main screen
                isTransferring = false
                loadMainScreen()
                
            } catch {
                print("❌ Transfer failed: \(error)")
                toastMessage = "Transfer failed: \(error.localizedDescription)"
                isTransferring = false
            }
        }
    }
    
    func cancelTransfer() {
        loadMainScreen()
    }
    
    // MARK: - APNs
    
    func setAPNsToken(_ token: String) {
        print("🟢 [RegistrationViewModel.setAPNsToken] Received token: \(token)")
        self.apnsToken = token
        print("🟢 [RegistrationViewModel.setAPNsToken] apnsToken stored: \(self.apnsToken ?? "nil")")
    }
    
    func setAPNsEnvironment(_ environment: String) {
        print("🟢 [RegistrationViewModel.setAPNsEnvironment] Received environment: \(environment)")
        self.apnsEnvironment = environment
        print("🟢 [RegistrationViewModel.setAPNsEnvironment] apnsEnvironment stored: \(self.apnsEnvironment ?? "nil")")
    }
    
    // MARK: - Network Status
    
    func showNetworkStatus() {
        Task {
            uiState = .loading
            
            do {
                let response = try await repository.getNetworkStatus()
                
                let ledgerStats = response.ledgerStats ?? LedgerStats(
                    totalAccounts: 0,
                    totalTransactions: 0,
                    totalMints: 0,
                    totalTransfers: 0,
                    totalMinted: 0
                )
                let iosCount = response.deviceStats?.ios?.count ?? 0
                let androidCount = response.deviceStats?.android?.count ?? 0
                
                uiState = .networkStatus(
                    ledgerStats: ledgerStats,
                    iosCount: iosCount,
                    androidCount: androidCount
                )
                
            } catch {
                print("❌ Failed to load network status: \(error)")
                toastMessage = "Failed to load network status: \(error.localizedDescription)"
                uiState = .error(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Settings
    
    func showSettings() {
        toastMessage = "Settings coming soon"
    }
    
    // MARK: - Toast
    
    func dismissToast() {
        toastMessage = nil
    }
}
