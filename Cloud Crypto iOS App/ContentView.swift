//
//  ContentView.swift
//  Cloud Crypto iOS App
//

import SwiftUI

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
                ZStack {
                    CryptoBackground()

                    mainContent
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                }
                .navigationTitle("Cloud Crypto")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .tint(AppColors.primary)

            // Toast overlay
            if let message = viewModel.toastMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(AppColors.onSurface)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.surface.opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary.opacity(0.6), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.bottom, 32)
                        .padding(.horizontal, 24)
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
            if let token = token {
                viewModel.setAPNsToken(token)
            }
        }
        .onReceive(apnsService.$tokenEnvironment) { environment in
            viewModel.setAPNsEnvironment(environment.rawValue)
        }
        .onChange(of: viewModel.navigationRequest) { _, newValue in
            if let request = newValue {
                navigationPath.append(request)
                viewModel.clearNavigationRequest()
            }
        }
        .onChange(of: viewModel.shouldPopNavigation) { _, shouldPop in
            if shouldPop {
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
                viewModel.clearPopNavigation()
            }
        }
        .onChange(of: navigationPath) { _, newPath in
            if newPath.isEmpty {
                switch viewModel.uiState {
                case .accountSummary, .networkStatus, .registrationForm, .transferScreen:
                    viewModel.loadMainScreen()
                default:
                    break
                }
            }
        }
    }

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
            LoadingView(message: "Loading...")
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        ZStack {
            CryptoBackground()

            switch destination {
            case .registration:
                RegistrationFormView(
                    serialNumber: $viewModel.serialNumber,
                    onRegister: { viewModel.registerDevice() },
                    onGenerateSerial: { viewModel.generateSerialNumber() },
                    onCancel: {
                        navigationPath.removeLast()
                        viewModel.loadMainScreen()
                    }
                )

            case .account:
                if case .accountSummary(let data, let transactions) = viewModel.uiState {
                    AccountSummaryView(data: data, transactions: transactions)
                } else {
                    LoadingView(message: "Loading account...")
                }

            case .transfer:
                TransferView(
                    toAccount: $viewModel.toAccount,
                    amount: $viewModel.amount,
                    memo: $viewModel.memo,
                    isTransferring: viewModel.isTransferring,
                    onSend: { viewModel.executeTransfer() },
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
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    ContentView()
        .environmentObject(APNsService())
}
