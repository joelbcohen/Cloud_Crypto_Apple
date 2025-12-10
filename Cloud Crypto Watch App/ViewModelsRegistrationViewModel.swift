//
//  RegistrationViewModel.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation
import SwiftUI
internal import Combine

/// Navigation destinations for NavigationStack
enum NavigationDestination: Hashable {
    case registrationForm
    case accountSummary(data: AccountSummaryData, transactions: [Transaction])
    case transferScreen
    case networkStatus(ledgerStats: LedgerStats, iosCount: Int, androidCount: Int)
}

/// Main view model for the app
@MainActor
class RegistrationViewModel: ObservableObject {

    @Published var navigationPath = NavigationPath()
    @Published var serialNumber: String = ""
    @Published var registeredSerialNumber: String?
    @Published var registrationTimestamp: TimeInterval = 0
    @Published var accountId: Int?
    @Published var toastMessage: String?
    @Published var toAccount: String = ""
    @Published var amount: String = ""
    @Published var memo: String = ""
    @Published var isTransferring: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showDeregisterConfirmation: Bool = false

    private let repository = RegistrationRepository()
    private var apnsToken: String?
    private var apnsEnvironment: String?
    
    // MARK: - Initialization

    init() {
        print("🟢 [RegistrationViewModel.init] ViewModel initialized, apnsToken is: \(apnsToken ?? "nil")")
        loadRegistrationStatus()
    }

    // MARK: - Main Screen

    func loadRegistrationStatus() {
        let status = repository.loadRegistrationStatus()
        registeredSerialNumber = status.serialNumber
        registrationTimestamp = status.registrationTimestamp
        accountId = status.accountId
    }

    var isRegistered: Bool {
        registeredSerialNumber != nil
    }
    
    // MARK: - Registration Form

    func showRegistrationForm() {
        serialNumber = ""
        navigationPath.append(NavigationDestination.registrationForm)
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
            isLoading = true

            do {
                let response = try await repository.registerDevice(
                    serialNumber: serialNumber,
                    apnsToken: apnsToken,
                    apnsEnvironment: apnsEnvironment
                )

                print("✅ Registration successful: \(response)")

                // Fetch account summary to ensure account ID is populated
                do {
                    let accountResponse = try await repository.getAccountSummary()
                    if let accountData = accountResponse.account, let accountId = accountData.id {
                        // Update stored account ID
                        let currentStatus = repository.loadRegistrationStatus()
                        let updatedStatus = RegistrationStatus(
                            isRegistered: currentStatus.isRegistered,
                            serialNumber: currentStatus.serialNumber,
                            registrationTimestamp: currentStatus.registrationTimestamp,
                            publicKey: currentStatus.publicKey,
                            privateKey: currentStatus.privateKey,
                            accountId: accountId
                        )
                        repository.saveRegistrationStatus(updatedStatus)
                        print("✅ Account ID \(accountId) saved after registration")
                    }
                } catch {
                    print("⚠️ Failed to fetch account ID after registration: \(error)")
                    // Continue anyway - account ID will be populated when user views account screen
                }

                toastMessage = response.message ?? "Registration successful"

                // Return to main screen - remove all navigation paths
                loadRegistrationStatus()
                navigationPath.removeLast(navigationPath.count)
                isLoading = false

            } catch {
                print("❌ Registration failed: \(error)")
                toastMessage = "Registration failed: \(error.localizedDescription)"
                errorMessage = error.localizedDescription
                isLoading = false
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
            isLoading = true

            do {
                let response = try await repository.deregisterDevice()

                print("✅ Deregistration successful: \(response)")

                toastMessage = response.message ?? "Deregistration successful"

                // Return to main screen
                loadRegistrationStatus()
                navigationPath.removeLast(navigationPath.count)
                isLoading = false

            } catch {
                print("❌ Deregistration failed: \(error)")
                toastMessage = "Deregistration failed: \(error.localizedDescription)"
                loadRegistrationStatus()
                isLoading = false
            }
        }
    }
    
    // MARK: - Account Screen

    func showAccountScreen() {
        Task {
            isLoading = true

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
                    isLoading = false
                    navigationPath.append(NavigationDestination.accountSummary(data: accountData, transactions: transactions))
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
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Transfer Screen

    func showTransferScreen() {
        toAccount = ""
        amount = ""
        memo = ""
        navigationPath.append(NavigationDestination.transferScreen)
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
                navigationPath.removeLast(navigationPath.count)

            } catch {
                print("❌ Transfer failed: \(error)")
                toastMessage = "Transfer failed: \(error.localizedDescription)"
                isTransferring = false
            }
        }
    }

    func cancelTransfer() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
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
            isLoading = true

            do {
                let response = try await repository.getNetworkStatus()

                let ledgerStats = response.ledgerStats ?? LedgerStats(
                    totalAccounts: 0,
                    totalTransactions: 0,
                    totalMints: 0,
                    totalTransfers: 0,
                    totalMinted: "0"
                )
                let iosCount = response.deviceStats?.ios?.count ?? 0
                let androidCount = response.deviceStats?.android?.count ?? 0

                isLoading = false
                navigationPath.append(NavigationDestination.networkStatus(
                    ledgerStats: ledgerStats,
                    iosCount: iosCount,
                    androidCount: androidCount
                ))

            } catch {
                print("❌ Failed to load network status: \(error)")
                toastMessage = "Failed to load network status: \(error.localizedDescription)"
                errorMessage = error.localizedDescription
                isLoading = false
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
