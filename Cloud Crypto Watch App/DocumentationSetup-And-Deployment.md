# Cloud Crypto watchOS - Setup and Deployment Guide

Complete guide for setting up, testing, and deploying the Cloud Crypto watchOS application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Development Configuration](#development-configuration)
4. [Testing](#testing)
5. [Deployment](#deployment)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- macOS Ventura 13.0 or later
- Xcode 15.0 or later
- Apple Watch Series 4 or later (for device testing)
- Apple Developer Account (for device testing and App Store)

### Required Knowledge

- Swift programming
- SwiftUI framework
- watchOS development basics
- REST API integration
- Push notification concepts

## Initial Setup

### 1. Create Xcode Project

If starting from scratch:

1. Open Xcode
2. Create New Project
3. Select watchOS > App
4. Name: "Cloud Crypto"
5. Interface: SwiftUI
6. Language: Swift

### 2. Add Files to Project

Copy all the source files into your Xcode project:

```
- Models/
- Services/
- Repositories/
- ViewModels/
- Views/
- Utilities/
- Complications/
```

### 3. Configure Bundle Identifier

1. Select project in Xcode
2. Select the Watch App target
3. Set Bundle Identifier: `com.yourcompany.cloudcrypto.watchapp`

### 4. Configure Signing

1. Select project > Signing & Capabilities
2. Select your Development Team
3. Xcode will automatically handle provisioning profiles

## Development Configuration

### 1. Add Required Capabilities

#### Push Notifications

1. Select Watch App target
2. Go to Signing & Capabilities
3. Click "+ Capability"
4. Add "Push Notifications"

#### Background Modes

1. Click "+ Capability"
2. Add "Background Modes"
3. Check ☑️ "Remote notifications"

#### Keychain Sharing (Optional)

1. Click "+ Capability"
2. Add "Keychain Sharing"
3. Add keychain group: `$(AppIdentifierPrefix)com.yourcompany.cloudcrypto`

### 2. Configure Info.plist

Add the following keys to your Info.plist:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>NSUserNotificationsUsageDescription</key>
<string>Cloud Crypto needs notification access to receive updates about your account and transactions.</string>
```

### 3. Configure APNs

#### Development APNs Certificate

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. Create new APNs Development Certificate
4. Download and install in Keychain

#### APNs Key (Recommended)

1. Go to Keys section
2. Create new Key
3. Enable Apple Push Notifications service (APNs)
4. Download .p8 key file
5. Save Key ID and Team ID for backend configuration

### 4. Configure Backend

Update your backend server with:

- APNs Key (.p8 file)
- Key ID
- Team ID
- Bundle Identifier

The backend should send notifications to:
- Development: `api.sandbox.push.apple.com`
- Production: `api.push.apple.com`

## Testing

### 1. Simulator Testing

#### Run on Simulator

1. Select Watch Simulator (e.g., Apple Watch Series 9 45mm)
2. Click Run (⌘R)
3. App will launch on simulator

#### Limitations

- Push notifications won't work on simulator
- Keychain Secure Enclave not available
- Some device info will be simulated

#### Test Cases for Simulator

- ✅ UI layout and navigation
- ✅ Registration form flow
- ✅ Account summary display
- ✅ Transfer input validation
- ✅ Loading states
- ✅ Error handling
- ✅ State persistence (UserDefaults)

### 2. Device Testing

#### Setup Physical Device

1. Pair Apple Watch with iPhone
2. Connect iPhone to Mac
3. Select Watch device in Xcode
4. Click Run

#### Enable Developer Mode (watchOS 9+)

1. On Watch: Settings > Privacy & Security > Developer Mode
2. Enable Developer Mode
3. Restart watch

#### Test Cases for Device

- ✅ Push notification registration
- ✅ Push notification reception
- ✅ Keychain operations
- ✅ RSA key generation
- ✅ Network requests
- ✅ Device info collection
- ✅ Complications update
- ✅ Real-world performance

### 3. Push Notification Testing

#### Using APNS Tool

1. Install Pusher app or command-line tool
2. Use your device token from logs
3. Send test notification:

```json
{
  "aps": {
    "alert": {
      "title": "Cloud Crypto",
      "body": "Test notification"
    },
    "sound": "default"
  },
  "type": "registration_update",
  "message": "Test message"
}
```

#### Using curl

```bash
curl -v \
  --header "apns-topic: com.yourcompany.cloudcrypto.watchapp" \
  --header "apns-push-type: alert" \
  --header "authorization: bearer [JWT_TOKEN]" \
  --data '{"aps":{"alert":"Test"}}' \
  --http2 \
  https://api.sandbox.push.apple.com/3/device/[DEVICE_TOKEN]
```

### 4. Complication Testing

#### Add Complication to Watch Face

1. On Watch, press and hold watch face
2. Tap Edit
3. Swipe to complications
4. Tap a complication slot
5. Scroll to find "Cloud Crypto"
6. Select desired complication style

#### Test Complication Updates

1. Register device in app
2. Check complication shows "REG"
3. Deregister device
4. Check complication shows "---"
5. Force update: Long press on face > Edit > Done

### 5. API Testing

#### Mock Server Setup

For development, you can use a mock server:

```bash
# Using json-server
npm install -g json-server
json-server --watch db.json --port 3000
```

Example `db.json`:

```json
{
  "register": {
    "status": "success",
    "message": "Registration successful",
    "accountId": "test-account-123"
  },
  "account_summary": {
    "status": "success",
    "account": {
      "balance": "10000.00",
      "total_sent_transactions": 5,
      "total_received_transactions": 3
    }
  }
}
```

#### Test Network Requests

1. Check Xcode console for request/response logs
2. Verify JSON encoding/decoding
3. Test error scenarios (timeout, invalid response)
4. Test with slow/unreliable network

## Deployment

### 1. Pre-Deployment Checklist

- [ ] All features tested on device
- [ ] Push notifications working
- [ ] Complications displaying correctly
- [ ] Error handling implemented
- [ ] Code commented and documented
- [ ] No debug print statements in production
- [ ] App icons added
- [ ] Version and build numbers updated
- [ ] Certificates and profiles configured

### 2. Build Configuration

#### Update Build Settings

1. Select project
2. Select Watch App target
3. Build Settings:
   - Optimization Level: -O (Optimize for Speed)
   - Swift Compilation Mode: Whole Module
   - Debug Information Format: DWARF with dSYM

#### Update Version Numbers

1. Increment CFBundleShortVersionString (e.g., 1.0 → 1.1)
2. Increment CFBundleVersion (e.g., 1 → 2)

### 3. Archive and Upload

#### Create Archive

1. Select "Any watchOS Device" as destination
2. Product > Archive
3. Wait for archive to complete
4. Archives organizer will open

#### Validate Archive

1. Select archive
2. Click "Validate App"
3. Choose App Store Connect distribution
4. Select signing options (Automatic recommended)
5. Wait for validation
6. Fix any issues

#### Upload to App Store Connect

1. Click "Distribute App"
2. Choose "App Store Connect"
3. Select signing options
4. Click "Upload"
5. Wait for processing

### 4. App Store Connect Configuration

#### App Information

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Fill in required information:
   - App Name
   - Subtitle
   - Primary Language
   - Category
   - Support URL
   - Privacy Policy URL

#### Version Information

1. What's New in This Version
2. Promotional Text
3. Description
4. Keywords
5. Screenshots (required for all watch sizes)

#### Watch-Only App Configuration

Since this is a standalone watch app:
- No iPhone app required
- Set "watchOS App" platform
- Provide watch screenshots only

### 5. TestFlight Distribution

#### Internal Testing

1. App Store Connect > TestFlight
2. Add internal testers
3. Testers receive email invitation
4. Install via TestFlight app on iPhone
5. App appears on paired watch

#### External Testing

1. Create external testing group
2. Add testers via email or public link
3. Submit for Beta App Review
4. Wait for approval (usually 24-48 hours)
5. Distribute to external testers

### 6. Production Release

#### Submit for Review

1. Complete all App Store Connect information
2. Add screenshots for all watch sizes
3. Set pricing and availability
4. Submit for review

#### Review Process

- Review time: 1-3 days typically
- May request additional info
- May reject if issues found
- Can appeal rejection if needed

#### Release Options

- **Manual Release**: You release after approval
- **Automatic Release**: Released immediately after approval
- **Scheduled Release**: Released on specific date

## Troubleshooting

### Build Issues

#### Signing Errors

```
Problem: "Provisioning profile doesn't include signing certificate"
Solution: 
1. Xcode > Preferences > Accounts
2. Select account > Download Manual Profiles
3. Or use Automatic signing
```

#### Missing Capabilities

```
Problem: "Push notification entitlement not found"
Solution:
1. Add Push Notifications capability
2. Clean build folder (⌘⇧K)
3. Rebuild
```

### Runtime Issues

#### App Crashes on Launch

1. Check Xcode console for crash logs
2. Verify all required files are included in target
3. Check for force-unwrapped optionals
4. Review initialization code

#### Network Requests Fail

1. Check URL is correct
2. Verify device has internet connection
3. Check App Transport Security settings
4. Review backend logs

#### Push Notifications Not Received

1. Verify APNs certificate is valid
2. Check device token is being sent to backend
3. Test with APNS testing tool
4. Check notification permission was granted

### Performance Issues

#### App Feels Slow

1. Profile with Instruments
2. Check for blocking operations on main thread
3. Optimize image loading
4. Reduce network request frequency

#### High Battery Usage

1. Minimize network requests
2. Avoid continuous background tasks
3. Use efficient data structures
4. Profile with Instruments (Energy Log)

### Deployment Issues

#### Archive Fails

1. Clean build folder
2. Update Xcode
3. Check certificate validity
4. Review build logs for specific errors

#### Validation Fails

1. Review validation errors
2. Update provisioning profiles
3. Check bundle identifier matches
4. Verify all required capabilities

## Best Practices

### Code Quality

- Use Swift concurrency (async/await)
- Follow MVVM architecture
- Keep views small and focused
- Use dependency injection
- Write unit tests for business logic

### Security

- Never commit keys or tokens
- Use Keychain for sensitive data
- Validate all user input
- Use HTTPS for all network requests
- Implement certificate pinning for production

### Performance

- Minimize network requests
- Cache appropriate data
- Use lazy loading
- Optimize images
- Profile regularly

### User Experience

- Provide clear feedback
- Show loading states
- Handle errors gracefully
- Keep UI responsive
- Support all watch sizes

## Resources

- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [App Distribution Guide](https://developer.apple.com/app-store/distribution/)
- [Push Notifications Guide](https://developer.apple.com/documentation/usernotifications)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

## Support

For issues or questions:
1. Check this documentation
2. Review Apple Developer Documentation
3. Search Stack Overflow
4. Contact your development team

---

Last Updated: November 20, 2025
