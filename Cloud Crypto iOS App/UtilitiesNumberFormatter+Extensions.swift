//
//  NumberFormatter+Extensions.swift
//  Cloud Crypto iOS App
//

import Foundation

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}

extension String {
    func formattedAsCurrency() -> String {
        guard let value = Double(self) else { return self }
        return NumberFormatter.currencyFormatter.string(from: NSNumber(value: value)) ?? self
    }

    func formatAsCurrency() -> String {
        formattedAsCurrency()
    }

    func formatAsInteger() -> String {
        guard let number = Int(self) else { return self }
        return NumberFormatter.integerFormatter.string(from: NSNumber(value: number)) ?? self
    }
}

extension Double {
    func formatAsCurrency() -> String {
        NumberFormatter.currencyFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int {
    func formatAsInteger() -> String {
        NumberFormatter.integerFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    func formattedAsNumber() -> String {
        formatAsInteger()
    }
}

extension DateFormatter {
    static let registrationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
}
