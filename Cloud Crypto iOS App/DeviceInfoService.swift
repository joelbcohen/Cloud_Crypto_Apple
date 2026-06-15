//
//  DeviceInfoService.swift
//  Cloud Crypto iOS App
//

import Foundation
import UIKit

actor DeviceInfoService {

    func getDeviceIdentifier() async -> String {
        let id = await MainActor.run { UIDevice.current.identifierForVendor?.uuidString }
        return id ?? UUID().uuidString
    }

    func getDeviceModel() async -> String {
        return await MainActor.run { UIDevice.current.model }
    }

    func getDeviceBrand() -> String {
        return "Apple"
    }

    func getOSVersion() async -> String {
        return await MainActor.run { UIDevice.current.systemVersion }
    }

    func generateSerialNumber() -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(uuid.prefix(10)).uppercased()
    }

    func collectDeviceInfo() async -> (id: String, model: String, brand: String, osVersion: String) {
        async let id = getDeviceIdentifier()
        async let model = getDeviceModel()
        async let osVersion = getOSVersion()
        return await (
            id: id,
            model: model,
            brand: getDeviceBrand(),
            osVersion: osVersion
        )
    }
}
