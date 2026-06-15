//
//  APNsService.swift
//  Cloud Crypto iOS App
//

import Foundation
internal import Combine
import UserNotifications
import UIKit

@MainActor
class APNsService: NSObject, ObservableObject {

    @Published var deviceToken: String?
    @Published var tokenEnvironment: APNsEnvironment = .sandbox
    @Published var notificationReceived: (type: String, message: String)?

    private let notificationCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await notificationCenter.requestAuthorization(options: options)
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func setDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        print("🔵 [APNsService.setDeviceToken] Setting token: \(token)")
        self.deviceToken = token
        self.tokenEnvironment = Self.detectAPNsEnvironment()
        print("🔵 [APNsService.setDeviceToken] Environment: \(tokenEnvironment.rawValue)")
    }

    static func detectAPNsEnvironment() -> APNsEnvironment {
        #if DEBUG
        return .sandbox
        #else
        guard let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
              let provisioningData = try? Data(contentsOf: URL(fileURLWithPath: provisioningPath)),
              let provisioningString = String(data: provisioningData, encoding: .ascii) else {
            return .production
        }

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

    func handleNotification(userInfo: [AnyHashable: Any]) {
        print("Received notification: \(userInfo)")

        if let type = userInfo["type"] as? String,
           let message = userInfo["message"] as? String {
            notificationReceived = (type: type, message: message)

            switch type {
            case "registration_update":
                NotificationCenter.default.post(name: .registrationUpdated, object: nil)
            case "config_update":
                print("Config update received")
            case "status_update":
                print("Status update received")
            default:
                print("Unknown notification type: \(type)")
            }
        }
    }
}

extension APNsService: UNUserNotificationCenterDelegate {

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

extension Notification.Name {
    static let registrationUpdated = Notification.Name("registrationUpdated")
    static let apnsTokenReceived = Notification.Name("apnsTokenReceived")
}

enum APNsEnvironment: String {
    case sandbox = "sandbox"
    case production = "production"
}
