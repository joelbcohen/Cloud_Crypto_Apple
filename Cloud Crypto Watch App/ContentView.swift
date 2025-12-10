//
//  ContentView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

/// Navigation destinations for the app
enum NavigationDestination: Hashable {
    case registration
    case account
    case transfer
    case network
}

struct ContentView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @EnvironmentObject private var apnsService: APNsService
    @State private var navigationPath = NavigationPath()

    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                // Main content based on UI state
                mainContent
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }

            // Toast Overlay
            if let message = viewModel.toastMessage {
                VStack {
                    Spacer()

                    Text(message)
                        .font(.caption)
                        .padding(8)
                        .background(Color.gray.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewModel.dismissToast()
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.toastMessage)
        .onReceive(apnsService.$deviceToken) { token in
            print("🟡 [ContentView.onReceive] deviceToken changed to: \(token ?? "nil")")
            if let token = token {
                print("🟡 [ContentView.onReceive] Calling viewModel.setAPNsToken")
                viewModel.setAPNsToken(token)
            } else {
                print("🟡 [ContentView.onReceive] Token is nil, not setting")
            }
        }
        .onReceive(apnsService.$tokenEnvironment) { environment in
            print("🟡 [ContentView.onReceive] tokenEnvironment changed to: \(environment.rawValue)")
            viewModel.setAPNsEnvironment(environment.rawValue)
        }
        // Listen for navigation requests from ViewModel
        .onChange(of: viewModel.navigationRequest) { _, newValue in
            if let request = newValue {
                handleNavigationRequest(request)
                viewModel.clearNavigationRequest()
            }
        }
        // Listen for pop navigation requests
        .onChange(of: viewModel.shouldPopNavigation) { _, shouldPop in
            if shouldPop {
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
                viewModel.clearPopNavigation()
            }
        }
    }

    // MARK: - Main Content View

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.uiState {
        case .mainScreen(let serialNumber, let timestamp, let accountId):
            MainScreenView(
                serialNumber: serialNumber,
                timestamp: timestamp,
                accountId: accountId,
                onRegister: {
                    viewModel.showRegistrationForm()
                    navigationPath.append(NavigationDestination.registration)
                },
                onDeregister: {
                    viewModel.confirmDeregister()
                },
                onAccount: {
                    viewModel.showAccountScreen()
                    navigationPath.append(NavigationDestination.account)
                },
                onTransfer: {
                    viewModel.showTransferScreen()
                    navigationPath.append(NavigationDestination.transfer)
                },
                onNetwork: {
                    viewModel.showNetworkStatus()
                    navigationPath.append(NavigationDestination.network)
                },
                onSettings: {
                    viewModel.showSettings()
                }
            )
            .navigationTitle("Cloud Crypto")
            .confirmationDialog(
                "Are you sure you want to deregister?",
                isPresented: $viewModel.showDeregisterConfirmation,
                titleVisibility: .visible
            ) {
                Button("Deregister", role: .destructive) {
                    viewModel.deregisterDevice()
                }
                Button("Cancel", role: .cancel) {}
            }

        case .loading:
            LoadingView(message: "Processing...")

        case .error(let message):
            ErrorView(
                message: message,
                onRetry: {
                    navigationPath = NavigationPath()
                    viewModel.loadMainScreen()
                }
            )

        default:
            // For other states that should be handled by navigation
            LoadingView(message: "Loading...")
        }
    }

    // MARK: - Navigation Destination Views

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .registration:
            RegistrationFormView(
                serialNumber: $viewModel.serialNumber,
                onRegister: {
                    viewModel.registerDevice()
                },
                onGenerateSerial: {
                    viewModel.generateSerialNumber()
                },
                onCancel: {
                    navigationPath.removeLast()
                    viewModel.loadMainScreen()
                }
            )

        case .account:
            if case .accountSummary(let data, let transactions) = viewModel.uiState {
                AccountSummaryView(
                    data: data,
                    transactions: transactions
                )
            } else {
                LoadingView(message: "Loading account...")
            }

        case .transfer:
            TransferView(
                toAccount: $viewModel.toAccount,
                amount: $viewModel.amount,
                memo: $viewModel.memo,
                isTransferring: viewModel.isTransferring,
                onSend: {
                    viewModel.executeTransfer()
                },
                onCancel: {
                    navigationPath.removeLast()
                    viewModel.cancelTransfer()
                }
            )

        case .network:
            if case .networkStatus(let ledgerStats, let iosCount, let androidCount) = viewModel.uiState {
                NetworkStatusView(
                    ledgerStats: ledgerStats,
                    iosCount: iosCount,
                    androidCount: androidCount
                )
            } else {
                LoadingView(message: "Loading network status...")
            }
        }
    }

    // MARK: - Navigation Handling

    private func handleNavigationRequest(_ request: NavigationDestination) {
        navigationPath.append(request)
    }
}

#Preview {
    ContentView()
        .environmentObject(APNsService())
}
