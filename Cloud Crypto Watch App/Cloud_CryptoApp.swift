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
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
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

// MARK: - Extension Delegate

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        print("✅ Application did finish launching")
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        print("✅ Registered for remote notifications")
        // Get the APNsService instance and set the token
        if let apnsService = WKExtension.shared().rootInterfaceController as? APNsService {
            Task { @MainActor in
                apnsService.setDeviceToken(deviceToken)
            }
        }
        
        // Also broadcast the token for other components
        NotificationCenter.default.post(
            name: .apnsTokenReceived,
            object: nil,
            userInfo: ["token": deviceToken]
        )
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let apnsTokenReceived = Notification.Name("apnsTokenReceived")
}

