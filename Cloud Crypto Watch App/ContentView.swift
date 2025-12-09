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
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            // Main Content
            Group {
                switch viewModel.uiState {
                case .mainScreen(let serialNumber, let timestamp, let accountId):
                    MainScreenView(
                        serialNumber: serialNumber,
                        timestamp: timestamp,
                        accountId: accountId,
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
                    
                case .registrationForm:
                    RegistrationFormView(
                        serialNumber: $viewModel.serialNumber,
                        onRegister: {
                            viewModel.registerDevice()
                        },
                        onGenerateSerial: {
                            viewModel.generateSerialNumber()
                        },
                        onCancel: {
                            viewModel.loadMainScreen()
                        }
                    )
                    
                case .accountSummary(let data, let transactions):
                    AccountSummaryView(
                        data: data,
                        transactions: transactions,
                        onBack: {
                            viewModel.loadMainScreen()
                        }
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
                        androidCount: androidCount,
                        onBack: {
                            viewModel.loadMainScreen()
                        }
                    )
                    
                case .loading:
                    LoadingView(message: "Processing...")
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        onRetry: {
                            viewModel.loadMainScreen()
                        }
                    )
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
    }
}

#Preview {
    ContentView()
        .environmentObject(APNsService())
}
