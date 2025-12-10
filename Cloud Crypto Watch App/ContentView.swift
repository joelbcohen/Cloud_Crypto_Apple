//
//  ContentView.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @EnvironmentObject private var apnsService: APNsService

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                // Main Screen
                MainScreenView(
                    serialNumber: viewModel.registeredSerialNumber,
                    timestamp: viewModel.registrationTimestamp,
                    accountId: viewModel.accountId,
                    onRegister: {
                        viewModel.showRegistrationForm()
                    },
                    onDeregister: {
                        viewModel.confirmDeregister()
                    },
                    onAccount: {
                        viewModel.showAccountScreen()
                    },
                    onTransfer: {
                        viewModel.showTransferScreen()
                    },
                    onNetwork: {
                        viewModel.showNetworkStatus()
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

                // Loading Overlay
                if viewModel.isLoading {
                    LoadingView(message: "Processing...")
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
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .registrationForm:
                    RegistrationFormView(
                        serialNumber: $viewModel.serialNumber,
                        onRegister: {
                            viewModel.registerDevice()
                        },
                        onGenerateSerial: {
                            viewModel.generateSerialNumber()
                        }
                    )

                case .accountSummary(let data, let transactions):
                    AccountSummaryView(
                        data: data,
                        transactions: transactions
                    )

                case .transferScreen:
                    TransferView(
                        toAccount: $viewModel.toAccount,
                        amount: $viewModel.amount,
                        memo: $viewModel.memo,
                        isTransferring: viewModel.isTransferring,
                        onSend: {
                            viewModel.executeTransfer()
                        },
                        onCancel: {
                            viewModel.cancelTransfer()
                        }
                    )

                case .networkStatus(let ledgerStats, let iosCount, let androidCount):
                    NetworkStatusView(
                        ledgerStats: ledgerStats,
                        iosCount: iosCount,
                        androidCount: androidCount
                    )
                }
            }
            .animation(.easeInOut, value: viewModel.toastMessage)
        }
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
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(APNsService())
}
