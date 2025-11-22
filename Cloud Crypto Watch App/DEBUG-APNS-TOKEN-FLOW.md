# Debug Guide: APNs Token Flow

## Overview
This guide shows you how to debug the APNs token flow from when it's received to when it's sent in the `/crypto/register` API call.

## Expected Log Flow

When everything works correctly, you should see these logs in order:

### 1. App Launch
```
🟢 [RegistrationViewModel.init] ViewModel initialized, apnsToken is: nil
```

### 2. APNs Token Received (from Apple)
```
✅ Registered for remote notifications
📱 Device Token: a1b2c3d4e5f6789abcdef...
✅ Token set on APNsService
```

### 3. Token Stored in APNsService
```
🔵 [APNsService.setDeviceToken] Setting token: a1b2c3d4e5f6789abcdef...
🔵 [APNsService.setDeviceToken] Token stored, deviceToken is now: a1b2c3d4e5f6789abcdef...
```

### 4. Token Propagated to ContentView
```
🟡 [ContentView.onReceive] deviceToken changed to: a1b2c3d4e5f6789abcdef...
🟡 [ContentView.onReceive] Calling viewModel.setAPNsToken
```

### 5. Token Stored in ViewModel
```
🟢 [RegistrationViewModel.setAPNsToken] Received token: a1b2c3d4e5f6789abcdef...
🟢 [RegistrationViewModel.setAPNsToken] apnsToken stored: a1b2c3d4e5f6789abcdef...
```

### 6. User Triggers Registration
```
📱 Registering with APNs token: a1b2c3d4e5f6789abcdef...
```

### 7. Repository Receives Token
```
🔧 [Repository] registerDevice called
🔧 [Repository] serialNumber: WATCH-12345
🔧 [Repository] apnsToken: a1b2c3d4e5f6789abcdef...
🔧 [Repository] Created RegistrationRequest:
🔧 [Repository]   - fcmToken: a1b2c3d4e5f6789abcdef...
🔧 [Repository]   - serialNumber: WATCH-12345
🔧 [Repository]   - id: device-uuid
```

### 8. NetworkService Encodes Request
```
🌐 [NetworkService] registerDevice called
🌐 [NetworkService] request.fcmToken: a1b2c3d4e5f6789abcdef...
🌐 [NetworkService] Encoded JSON: {"serialNumber":"...","fcmToken":"a1b2c3d4e5f6789abcdef...",...}
```

### 9. HTTP Request Sent
```
📡 Request: POST https://fusio.callista.io/public/crypto/register
📤 Body: {"serialNumber":"...","fcmToken":"a1b2c3d4e5f6789abcdef...",...}
```

## Xcode Breakpoints

Set breakpoints at these locations to inspect values:

### Breakpoint 1: ExtensionDelegate
**File:** `Cloud_CryptoApp.swift`
**Line:** Inside `didRegisterForRemoteNotifications(withDeviceToken:)`
**Inspect:**
- `deviceToken` (Data)
- `tokenString` (String)
- `ExtensionDelegate.apnsService` (should not be nil)

### Breakpoint 2: APNsService
**File:** `APNsService.swift`
**Line:** Inside `setDeviceToken(_:)`
**Inspect:**
- `tokenData` (Data)
- `token` (String)
- `self.deviceToken` (after assignment)

### Breakpoint 3: ContentView
**File:** `ContentView.swift`
**Line:** Inside `.onReceive(apnsService.$deviceToken)`
**Inspect:**
- `token` (String?)
- `apnsService.deviceToken` (String?)

### Breakpoint 4: RegistrationViewModel (Token Set)
**File:** `ViewModelsRegistrationViewModel.swift`
**Line:** Inside `setAPNsToken(_:)`
**Inspect:**
- `token` (String parameter)
- `self.apnsToken` (after assignment)

### Breakpoint 5: RegistrationViewModel (Register)
**File:** `ViewModelsRegistrationViewModel.swift`
**Line:** Inside `registerDevice()`, before calling repository
**Inspect:**
- `self.apnsToken` (should not be nil)
- `serialNumber`

### Breakpoint 6: Repository
**File:** `RepositoriesRegistrationRepository.swift`
**Line:** Inside `registerDevice(serialNumber:apnsToken:)`
**Inspect:**
- `apnsToken` (String? parameter)
- `request.fcmToken` (after creating RegistrationRequest)

### Breakpoint 7: NetworkService
**File:** `NetworkService.swift`
**Line:** Inside `registerDevice(_:)`, after encoding
**Inspect:**
- `request.fcmToken`
- `body` (Data - view as String to see JSON)

## Common Issues

### Issue 1: Token Never Received
**Symptoms:**
- Never see "✅ Registered for remote notifications"
- Never see ExtensionDelegate logs

**Solutions:**
- Check notification permissions are granted
- Check the app has proper entitlements
- Check device/simulator supports push notifications
- Verify provisioning profile includes push notifications

### Issue 2: Token Not Propagating to ViewModel
**Symptoms:**
- See token in APNsService logs
- Never see ContentView.onReceive logs

**Solutions:**
- Verify `@EnvironmentObject` is properly set in App
- Check that ContentView has access to APNsService
- Ensure the publisher is actually publishing

### Issue 3: Token is Nil During Registration
**Symptoms:**
- See "⚠️ WARNING: Registering without APNs token!"
- User registers before token arrives

**Solutions:**
- This is a timing issue
- Consider disabling registration until token arrives
- Or allow registration and update token later

### Issue 4: Token Stripped from JSON
**Symptoms:**
- Token is in the struct but not in the JSON body
- See token in Repository logs but not in NetworkService JSON

**Solutions:**
- This means the token is `nil` and JSONEncoder is omitting it
- The token is being lost somewhere in the chain

## How to View Logs in Xcode

1. **Console:** Window → Show Console (⇧⌘C)
2. **Filter logs:** Type your emoji prefix in the filter box:
   - 🔵 for APNsService
   - 🟡 for ContentView
   - 🟢 for RegistrationViewModel
   - 🔧 for Repository
   - 🌐 for NetworkService
   - 📡 for HTTP requests

3. **Save logs:** Right-click in console → Save Log As...

## Next Steps

1. Run the app with these enhanced logs
2. Look for where the logs stop or show unexpected values
3. Share the logs showing the problem area
4. We can then pinpoint exactly where the token is being lost
