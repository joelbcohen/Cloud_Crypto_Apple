# Cloud Crypto - watchOS App

A native Apple watchOS application for cryptocurrency wallet/account management on wearable devices with device registration, account viewing, and transfer capabilities.

## Overview

Cloud Crypto is a watchOS app that replicates the functionality of the Android Wear OS "Cloud Crypto" app. It provides secure device registration, account management, and cryptocurrency transfer capabilities directly from your Apple Watch.

## Features

- ✅ **Device Registration**: Register your Apple Watch with auto-generated UUID serial numbers
- ✅ **Account Summary**: View balance, transaction statistics, and device information
- ✅ **Transfer Funds**: Send cryptocurrency to other accounts
- ✅ **Push Notifications**: Receive updates via APNs
- ✅ **Watch Complications**: Quick status view on watch face
- ✅ **Secure Storage**: RSA key pairs stored in Keychain
- ✅ **Device Attestation**: Secure device verification

## Requirements

- watchOS 9.0 or later
- Apple Watch Series 4 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Project Structure

```
CloudCryptoWatch/
├── Cloud_CryptoApp.swift           # App entry point with APNs setup
├── ContentView.swift               # Root view with state management
├── ViewModels/
│   └── RegistrationViewModel.swift # Main view model
├── Views/
│   ├── MainScreenView.swift        # Main screen
│   ├── RegistrationFormView.swift  # Registration input
│   ├── AccountSummaryView.swift    # Account summary
│   ├── TransferView.swift          # Transfer screen
│   ├── LoadingView.swift           # Loading state
│   └── ErrorView.swift             # Error state
├── Models/
│   ├── RegistrationModels.swift    # Request/Response models
│   ├── AccountModels.swift         # Account data models
│   └── RegistrationStatus.swift    # Local status model
├── Services/
│   ├── NetworkService.swift        # API client
│   ├── DeviceInfoService.swift     # Device info collection
│   ├── KeychainService.swift       # Keychain operations
│   ├── AttestationService.swift    # Key generation & attestation
│   └── APNsService.swift           # Push notification handling
├── Repositories/
│   └── RegistrationRepository.swift # Data layer
├── Utilities/
│   ├── UserDefaultsManager.swift   # Persistence helper
│   └── NumberFormatter+Extensions.swift # Number formatting
└── Complications/
    └── CloudCryptoComplication.swift # Complication provider
```

## Setup Instructions

### 1. Clone the Project

```bash
git clone <repository-url>
cd CloudCryptoWatch
```

### 2. Configure Apple Developer Settings

1. Open the project in Xcode
2. Select your Development Team in Signing & Capabilities
3. Update the Bundle Identifier if needed

### 3. Enable Required Capabilities

In Xcode, go to Signing & Capabilities and add:

- **Push Notifications**: For APNs support
- **Background Modes**: Check "Remote notifications"
- **Keychain Sharing**: Optional, for shared keychain access

### 4. Configure APNs

1. Create an APNs certificate or key in Apple Developer Portal
2. Configure your backend to accept APNs device tokens
3. The app will automatically request notification permission on launch

### 5. Backend API Configuration

The app connects to: `https://fusio.callista.io/`

Ensure the following endpoints are available:
- POST `/public/crypto/register`
- POST `/public/crypto/deregister`
- POST `/public/crypto/account_summary`
- POST `/public/crypto/transfer`

### 6. Build and Run

1. Select your Apple Watch simulator or device
2. Click Run in Xcode
3. The app will launch on your watch

## Usage

### First Time Setup

1. Launch the app on your Apple Watch
2. Tap "REGISTER" button
3. Either enter a serial number or tap "Generate" for auto-generation
4. Tap "REGISTER" to complete registration

### View Account

1. From the main screen, tap "ACCOUNT"
2. View your balance and transaction statistics
3. Tap "BACK" to return to main screen

### Transfer Funds

1. From the main screen, tap "TRANSFER"
2. Enter the destination account ID
3. Enter the amount to send
4. Tap "SEND" to execute the transfer
5. Wait for confirmation

### Deregister Device

1. From the main screen, tap "DE-REGISTER"
2. Confirm deregistration
3. All local data will be cleared

### Watch Complications

1. Customize your watch face
2. Add the Cloud Crypto complication
3. Shows "REG" when registered, "---" when not registered

## Architecture

### MVVM Pattern

- **Views**: SwiftUI views that display UI
- **ViewModels**: Observable objects that manage state
- **Models**: Data structures for API and local storage
- **Services**: Business logic and API communication
- **Repository**: Data access layer

### Data Flow

1. User interacts with View
2. View calls ViewModel method
3. ViewModel uses Repository
4. Repository calls Services
5. Services communicate with API or storage
6. Results flow back through the chain

### Security

- **RSA 2048-bit keys** generated and stored in Keychain
- **Device attestation** using public key export
- **Secure storage** with `kSecAttrAccessibleAfterFirstUnlock`
- **APNs tokens** securely transmitted to backend

## API Documentation

### Register Device

**Endpoint**: POST `/public/crypto/register`

**Request**:
```json
{
  "serialNumber": "ABC-123-DEF-456",
  "id": "device-uuid",
  "fcmToken": "apns-token",
  "publicKey": "base64-encoded-key",
  "attestationBlob": "base64-attestation",
  "deviceModel": "Apple Watch Series 9",
  "deviceBrand": "Apple",
  "osVersion": "10.0"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Registration successful",
  "registrationId": "reg-id",
  "publicKey": "public-key",
  "accountId": "account-id",
  "remainingBalance": 0.0
}
```

### Account Summary

**Endpoint**: POST `/public/crypto/account_summary`

**Request**:
```json
{
  "serialNumber": "ABC-123-DEF-456",
  "publicKey": "base64-encoded-key",
  "attestationBlob": "base64-attestation"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Account retrieved",
  "account": {
    "id": "account-id",
    "balance": "12345.67",
    "total_sent_transactions": 5,
    "total_received_transactions": 3,
    "total_sent_amount": "1234.56",
    "total_received_amount": "11111.11"
  }
}
```

### Transfer

**Endpoint**: POST `/public/crypto/transfer`

**Request**:
```json
{
  "serialNumber": "ABC-123-DEF-456",
  "publicKey": "base64-encoded-key",
  "attestationBlob": "base64-attestation",
  "toAccountId": "destination-account-id",
  "amount": "100.00"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Transfer successful",
  "transactionId": "txn-id",
  "newBalance": "12245.67"
}
```

## Push Notifications

### Notification Payload

```json
{
  "aps": {
    "alert": {
      "title": "Cloud Crypto",
      "body": "Your device registration has been confirmed"
    },
    "sound": "default"
  },
  "type": "registration_update",
  "serialNumber": "ABC123",
  "status": "active",
  "message": "Your device registration has been confirmed"
}
```

### Notification Types

- `registration_update`: Device registration status changed
- `config_update`: Configuration updated
- `status_update`: Account status changed

## Troubleshooting

### App Not Registering

1. Check network connectivity
2. Verify backend API is accessible
3. Check Xcode console for error messages
4. Ensure serial number is not empty

### Push Notifications Not Working

1. Verify Push Notifications capability is enabled
2. Check APNs certificate is configured
3. Ensure notification permission was granted
4. Check Extension Delegate is receiving token

### Keys Not Generating

1. Check Keychain access permissions
2. Verify device supports Secure Enclave
3. Check for existing keys that need to be deleted
4. Review Xcode console for security errors

### Complications Not Updating

1. Force-touch watch face and re-add complication
2. Check widget timeline is being refreshed
3. Verify registration status is saved correctly
4. Restart watch if needed

## Testing Checklist

- [ ] First launch shows registration option
- [ ] Serial number can be generated
- [ ] Registration saves data locally
- [ ] Account summary displays correctly
- [ ] Transfer validates inputs
- [ ] Deregistration clears data
- [ ] Push notifications are received
- [ ] Complications update on status change
- [ ] Loading states display properly
- [ ] Error messages are shown
- [ ] App state persists across launches

## Performance Considerations

- Network requests timeout after 30 seconds
- UserDefaults used for lightweight persistence
- Keychain used for sensitive data
- Async/await for non-blocking operations
- Main actor used for UI updates

## Future Enhancements

- [ ] Settings screen implementation
- [ ] Transaction history view
- [ ] Multiple account support
- [ ] Biometric authentication
- [ ] QR code scanning for account IDs
- [ ] Rich notifications with actions
- [ ] Live Activities support
- [ ] Dark mode optimization

## License

Copyright © 2025 Joel Cohen. All rights reserved.

## Support

For issues, questions, or contributions, please contact the development team.

---

Built with ❤️ using Swift and SwiftUI for watchOS
