//
//  NumberFormatter+Extensions.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import Foundation

extension NumberFormatter {
    /// Formatter for currency amounts with comma separators
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    /// Formatter for integer amounts with comma separators
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
    /// Formats a string number with comma separators (with 2 decimal places)
    func formattedAsCurrency() -> String {
        guard let value = Double(self) else { return self }
        return NumberFormatter.currencyFormatter.string(from: NSNumber(value: value)) ?? self
    }
    
    /// Alias for formattedAsCurrency for consistency
    func formatAsCurrency() -> String {
        formattedAsCurrency()
    }
    
    /// Formats a string number as integer with comma separators
    func formatAsInteger() -> String {
        guard let number = Int(self) else { return self }
        return NumberFormatter.integerFormatter.string(from: NSNumber(value: number)) ?? self
    }
}

extension Double {
    /// Formats a double as currency string
    func formatAsCurrency() -> String {
        NumberFormatter.currencyFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension Int {
    /// Formats an integer with comma separators
    func formatAsInteger() -> String {
        NumberFormatter.integerFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension DateFormatter {
    /// Formatter for registration date (MMM dd, yyyy)
    static let registrationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
}
