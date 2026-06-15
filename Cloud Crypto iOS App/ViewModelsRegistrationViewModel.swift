//
//  RegistrationViewModel.swift
//  Cloud Crypto iOS App
//

import Foundation
import SwiftUI
internal import Combine

enum RegistrationUiState: Equatable {
    case mainScreen(serialNumber: String?, timestamp: TimeInterval, accountId: Int?)
    case registrationForm
    case accountSummary(data: AccountSummaryData, transactions: [Transaction])
    case transferScreen
    case networkStatus(ledgerStats: LedgerStats, iosCount: Int, androidCount: Int)
    case loading
    case error(message: String)
}

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

    @Published var navigationRequest: NavigationDestination?
    @Published var shouldPopNavigation: Bool = false

    private let repository = RegistrationRepository()
    private var apnsToken: String?
    private var apnsEnvironment: String?

    init() {
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

    // MARK: - Registration

    func showRegistrationForm() {
        uiState = .registrationForm
        serialNumber = ""
    }

    func registerDevice() {
        guard !serialNumber.isEmpty else {
            toastMessage = "Please enter a serial number"
            return
        }

        Task {
            uiState = .loading

            do {
                let response = try await repository.registerDevice(
                    serialNumber: serialNumber,
                    apnsToken: apnsToken,
                    apnsEnvironment: apnsEnvironment
                )

                // Try to populate account ID immediately
                do {
                    let accountResponse = try await repository.getAccountSummary()
                    if let accountData = accountResponse.account, let accountId = accountData.id {
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
                    }
                } catch {
                    print("⚠️ Failed to fetch account ID after registration: \(error)")
                }

                toastMessage = response.message ?? "Registration successful"
                loadMainScreen()
                popNavigation()

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
                toastMessage = response.message ?? "Deregistration successful"
                loadMainScreen()
            } catch {
                toastMessage = "Deregistration failed: \(error.localizedDescription)"
                loadMainScreen()
            }
        }
    }

    // MARK: - Account

    func showAccountScreen() {
        Task {
            uiState = .loading

            do {
                let response = try await repository.getAccountSummary()

                if let accountData = response.account {
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
                toastMessage = "Failed to load account: \(error.localizedDescription)"
                uiState = .error(message: error.localizedDescription)
            }
        }
    }

    // MARK: - Transfer

    func showTransferScreen() {
        uiState = .transferScreen
        toAccount = ""
        amount = ""
        memo = ""
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
                toastMessage = response.message ?? "Transfer successful"
                isTransferring = false
                loadMainScreen()
                popNavigation()
            } catch {
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
        self.apnsToken = token
    }

    func setAPNsEnvironment(_ environment: String) {
        self.apnsEnvironment = environment
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
                toastMessage = "Failed to load network status: \(error.localizedDescription)"
                uiState = .error(message: error.localizedDescription)
            }
        }
    }

    func showSettings() {
        toastMessage = "Settings coming soon"
    }

    // MARK: - Toast / Navigation

    func dismissToast() {
        toastMessage = nil
    }

    func clearNavigationRequest() {
        navigationRequest = nil
    }

    func clearPopNavigation() {
        shouldPopNavigation = false
    }

    func popNavigation() {
        shouldPopNavigation = true
    }
}
