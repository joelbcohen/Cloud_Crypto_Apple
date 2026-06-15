//
//  AppColors.swift
//  Cloud Crypto iOS App
//
//  Color palette mirrored from the Cloud Crypto Android app.
//

import SwiftUI

enum AppColors {
    // Brand
    static let primary       = Color(red: 0x00 / 255.0, green: 0xD4 / 255.0, blue: 0xAA / 255.0) // #00D4AA
    static let secondary     = Color(red: 0x7C / 255.0, green: 0x4D / 255.0, blue: 0xFF / 255.0) // #7C4DFF
    static let tertiary      = Color(red: 0x3B / 255.0, green: 0x82 / 255.0, blue: 0xF6 / 255.0) // #3B82F6

    // Surfaces
    static let background    = Color(red: 0x0D / 255.0, green: 0x1B / 255.0, blue: 0x2A / 255.0) // #0D1B2A
    static let surface       = Color(red: 0x1B / 255.0, green: 0x28 / 255.0, blue: 0x38 / 255.0) // #1B2838
    static let surfaceVariant = Color(red: 0x1E / 255.0, green: 0x30 / 255.0, blue: 0x48 / 255.0) // #1E3048

    // Text
    static let onSurface     = Color(red: 0xE0 / 255.0, green: 0xE6 / 255.0, blue: 0xED / 255.0) // #E0E6ED
    static let onSurfaceMuted = Color(red: 0xA0 / 255.0, green: 0xB0 / 255.0, blue: 0xC0 / 255.0) // #A0B0C0

    // Accents for stats and transactions
    static let statAccounts     = Color(red: 0x4C / 255.0, green: 0xAF / 255.0, blue: 0x50 / 255.0) // #4CAF50
    static let statTransactions = Color(red: 0x21 / 255.0, green: 0x96 / 255.0, blue: 0xF3 / 255.0) // #2196F3
    static let statMints        = Color(red: 0xFF / 255.0, green: 0x98 / 255.0, blue: 0x00 / 255.0) // #FF9800
    static let statTransfers    = Color(red: 0x9C / 255.0, green: 0x27 / 255.0, blue: 0xB0 / 255.0) // #9C27B0
    static let statMinted       = Color(red: 0xFF / 255.0, green: 0xEB / 255.0, blue: 0x3B / 255.0) // #FFEB3B

    static let deviceApple   = Color(red: 0x64 / 255.0, green: 0xB5 / 255.0, blue: 0xF6 / 255.0) // #64B5F6
    static let deviceGoogle  = Color(red: 0x81 / 255.0, green: 0xC7 / 255.0, blue: 0x84 / 255.0) // #81C784

    static let success       = Color(red: 0x4C / 255.0, green: 0xAF / 255.0, blue: 0x50 / 255.0)
    static let sent          = Color(red: 0xFF / 255.0, green: 0x98 / 255.0, blue: 0x00 / 255.0)
    static let received      = Color(red: 0x21 / 255.0, green: 0x96 / 255.0, blue: 0xF3 / 255.0)
    static let bitcoin       = Color(red: 0xF7 / 255.0, green: 0x93 / 255.0, blue: 0x1A / 255.0)
    static let danger        = Color(red: 0xEF / 255.0, green: 0x53 / 255.0, blue: 0x50 / 255.0)
}
