//
//  DeviceInfoService.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation
import WatchKit

/// Service for collecting device information
actor DeviceInfoService {
    
    // MARK: - Device Info
    
    func getDeviceIdentifier() -> String {
        let device = WKInterfaceDevice.current()
        return device.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    func getDeviceModel() -> String {
        return WKInterfaceDevice.current().model
    }
    
    func getDeviceBrand() -> String {
        return "Apple"
    }
    
    func getOSVersion() -> String {
        return WKInterfaceDevice.current().systemVersion
    }
    
    func generateSerialNumber() -> String {
        // Generate UUID, remove hyphens, and take first 20 characters
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(uuid.prefix(10)).uppercased()
    }
    
    /// Collects all device information for registration
    func collectDeviceInfo() -> (id: String, model: String, brand: String, osVersion: String) {
        return (
            id: getDeviceIdentifier(),
            model: getDeviceModel(),
            brand: getDeviceBrand(),
            osVersion: getOSVersion()
        )
    }
}
