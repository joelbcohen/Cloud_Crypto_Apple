//
//  Cloud_CryptoApp.swift
//  Cloud Crypto iOS App
//

import SwiftUI
import UIKit

@main
struct Cloud_Crypto_iOS_AppApp: App {
    @StateObject private var apnsService = APNsService()
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) var applicationDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apnsService)
                .preferredColorScheme(.dark)
                .onAppear {
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

// MARK: - Application Delegate

class ApplicationDelegate: NSObject, UIApplicationDelegate {

    static var apnsService: APNsService?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("✅ Application did finish launching")
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(tokenString)")

        Task { @MainActor in
            if let apnsService = ApplicationDelegate.apnsService {
                apnsService.setDeviceToken(deviceToken)
            } else {
                NotificationCenter.default.post(
                    name: .apnsTokenReceived,
                    object: nil,
                    userInfo: ["token": deviceToken]
                )
            }
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
}
