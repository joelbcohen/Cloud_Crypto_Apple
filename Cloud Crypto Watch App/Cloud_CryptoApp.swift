//
//  Cloud_CryptoApp.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI
import WatchKit

@main
struct Cloud_Crypto_Watch_AppApp: App {
    @StateObject private var apnsService = APNsService()
    
    init() {
        // Additional initialization if needed
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apnsService)
                .onAppear {
                    requestNotificationPermission()
                }
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await apnsService.requestAuthorization()
                if granted {
                    await MainActor.run {
                        apnsService.registerForRemoteNotifications()
                    }
                }
            } catch {
                print("❌ Failed to request notification authorization: \(error)")
            }
        }
    }
}
