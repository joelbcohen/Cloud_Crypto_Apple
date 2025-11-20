# Info.plist Configuration Guide

This document describes the required Info.plist configurations for the Cloud Crypto watchOS app.

## Required Configurations

### 1. Push Notifications

Add the following to enable background push notifications:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### 2. Keychain Access

The app uses Keychain for secure storage. Ensure Keychain Sharing capability is configured in Xcode.

### 3. Privacy - User Notifications

Add a description for why the app needs notification access:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Cloud Crypto needs notification access to receive updates about your account and transactions.</string>
```

### 4. Bundle Configuration

Standard bundle configuration:

```xml
<key>CFBundleDisplayName</key>
<string>Cloud Crypto</string>

<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>CFBundleShortVersionString</key>
<string>1.0</string>
```

### 5. WatchKit Configuration

```xml
<key>WKApplication</key>
<true/>

<key>WKWatchOnly</key>
<true/>
```

### 6. App Transport Security (if needed)

If your backend doesn't use HTTPS, you'll need to configure ATS (not recommended for production):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>fusio.callista.io</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

## Complete Sample Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Cloud Crypto</string>
    
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    
    <key>WKApplication</key>
    <true/>
    
    <key>WKWatchOnly</key>
    <true/>
    
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
    
    <key>NSUserNotificationsUsageDescription</key>
    <string>Cloud Crypto needs notification access to receive updates about your account and transactions.</string>
    
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
</dict>
</plist>
```

## Xcode Capabilities

In addition to Info.plist, configure these capabilities in Xcode:

### 1. Push Notifications
- Go to Signing & Capabilities
- Click "+ Capability"
- Add "Push Notifications"

### 2. Background Modes
- Go to Signing & Capabilities
- Click "+ Capability"
- Add "Background Modes"
- Check "Remote notifications"

### 3. Keychain Sharing (Optional)
- Go to Signing & Capabilities
- Click "+ Capability"
- Add "Keychain Sharing"
- Add keychain group if needed

## Entitlements

The app will need an entitlements file with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
    <!-- Change to 'production' for App Store builds -->
    
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.cloudcrypto.watch</string>
    </array>
</dict>
</plist>
```

## Notes

- Make sure to update bundle identifier to match your team
- APNs environment should be 'development' for testing and 'production' for release
- All privacy descriptions should be clear about data usage
- Test on both simulator and physical device

---

For more information, see Apple's [Information Property List Key Reference](https://developer.apple.com/documentation/bundleresources/information_property_list).
