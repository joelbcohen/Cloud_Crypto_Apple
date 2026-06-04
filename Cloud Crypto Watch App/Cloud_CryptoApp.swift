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
    @WKApplicationDelegateAdaptor(ApplicationDelegate.self) var applicationDelegate
    
    init() {
        // Store reference to APNsService for the extension delegate
        // This will be set before the app scene is created
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apnsService)
                .onAppear {
                    // Set the static reference after StateObject is initialized
                    ApplicationDelegate.apnsService = apnsService
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

class ApplicationDelegate: NSObject, WKApplicationDelegate {
    
    // Shared reference to APNsService
    static var apnsService: APNsService?
    
    func applicationDidFinishLaunching() {
        print("✅ Application did finish launching")
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        print("✅ Registered for remote notifications")
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(tokenString)")
        
        // Set the token on the APNsService instance
        Task { @MainActor in
            if let apnsService = ApplicationDelegate.apnsService {
                apnsService.setDeviceToken(deviceToken)
                print("✅ Token set on APNsService")
            } else {
                print("⚠️ APNsService not available, broadcasting via NotificationCenter")
                // Fallback: broadcast the token for other components
                NotificationCenter.default.post(
                    name: .apnsTokenReceived,
                    object: nil,
                    userInfo: ["token": deviceToken]
                )
            }
        }
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let apnsTokenReceived = Notification.Name("apnsTokenReceived")
}

