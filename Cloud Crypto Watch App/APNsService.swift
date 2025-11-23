//
//  APNsService.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation
internal import Combine
import UserNotifications
import WatchKit

/// Service for handling Apple Push Notifications
@MainActor
class APNsService: NSObject, ObservableObject {
    
    @Published var deviceToken: String?
    @Published var tokenEnvironment: APNsEnvironment = .sandbox
    @Published var notificationReceived: (type: String, message: String)?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await notificationCenter.requestAuthorization(options: options)
    }
    
    // MARK: - Token Registration
    
    func registerForRemoteNotifications() {
        WKExtension.shared().registerForRemoteNotifications()
    }
    
    func setDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        print("🔵 [APNsService.setDeviceToken] Setting token: \(token)")
        self.deviceToken = token
        
        // Detect APNs environment
        self.tokenEnvironment = Self.detectAPNsEnvironment()
        print("🔵 [APNsService.setDeviceToken] Environment: \(tokenEnvironment.rawValue)")
        print("🔵 [APNsService.setDeviceToken] Token stored, deviceToken is now: \(self.deviceToken ?? "nil")")
    }
    
    /// Detects whether the app is using APNs sandbox or production environment
    static func detectAPNsEnvironment() -> APNsEnvironment {
        #if DEBUG
        return .sandbox
        #else
        // Check if embedded.mobileprovision exists (App Store builds don't have it)
        guard let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
              let provisioningData = try? Data(contentsOf: URL(fileURLWithPath: provisioningPath)),
              let provisioningString = String(data: provisioningData, encoding: .ascii) else {
            // No provisioning profile = App Store/TestFlight = production
            return .production
        }
        
        // Check if the provisioning profile contains "aps-environment" = "production"
        if provisioningString.contains("<key>aps-environment</key>") &&
           provisioningString.contains("<string>production</string>") {
            return .production
        }
        
        return .sandbox
        #endif
    }
    
    func handleRegistrationError(_ error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Notification Handling
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        print("Received notification: \(userInfo)")
        
        // Extract notification type and message
        if let type = userInfo["type"] as? String,
           let message = userInfo["message"] as? String {
            notificationReceived = (type: type, message: message)
            
            // Handle specific notification types
            switch type {
            case "registration_update":
                handleRegistrationUpdate(userInfo: userInfo)
            case "config_update":
                handleConfigUpdate(userInfo: userInfo)
            case "status_update":
                handleStatusUpdate(userInfo: userInfo)
            default:
                print("Unknown notification type: \(type)")
            }
        }
    }
    
    private func handleRegistrationUpdate(userInfo: [AnyHashable: Any]) {
        print("Registration update received")
        // Update complications or refresh UI
        NotificationCenter.default.post(name: .registrationUpdated, object: nil)
    }
    
    private func handleConfigUpdate(userInfo: [AnyHashable: Any]) {
        print("Config update received")
        // Handle configuration changes
    }
    
    private func handleStatusUpdate(userInfo: [AnyHashable: Any]) {
        print("Status update received")
        // Handle status changes
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension APNsService: UNUserNotificationCenterDelegate {
    
    /// Called when notification arrives while app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task { @MainActor in
            handleNotification(userInfo: notification.request.content.userInfo)
        }
        completionHandler([.banner, .sound])
    }
    
    /// Called when user interacts with notification
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            handleNotification(userInfo: response.notification.request.content.userInfo)
        }
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let registrationUpdated = Notification.Name("registrationUpdated")
}

// MARK: - APNs Environment

enum APNsEnvironment: String {
    case sandbox = "sandbox"
    case production = "production"
}
