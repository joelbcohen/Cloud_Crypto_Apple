# Cloud Crypto watchOS - Quick Start Guide

Get up and running with the Cloud Crypto watchOS app in minutes!

## 🚀 5-Minute Setup

### Step 1: Open Project
```bash
cd CloudCryptoWatch
open CloudCryptoWatch.xcodeproj
```

### Step 2: Select Target
- In Xcode, select the Watch App target
- Choose a simulator: Apple Watch Series 9 (45mm)

### Step 3: Run
- Press ⌘R or click the Run button
- Wait for simulator to launch
- App will appear on the watch screen

### Step 4: Test Registration
1. Tap "REGISTER" button
2. Tap "Generate" to create serial number
3. Tap "REGISTER" to complete
4. See main screen with serial number

**Note**: Network requests will fail without backend configuration, but you can test the UI flow.

## 🔧 Common Tasks

### Test on Physical Device

1. **Pair your Apple Watch with iPhone**
2. **Connect iPhone to Mac**
3. **Select your Watch in Xcode**
   - Window > Devices and Simulators
   - Select your watch
4. **Enable Developer Mode** (watchOS 9+)
   - Watch: Settings > Privacy & Security > Developer Mode
   - Enable and restart
5. **Run from Xcode**
   - Select your watch as destination
   - Press ⌘R

### Configure Backend API

**Option 1: Use Mock Server**

Create a mock server for testing:

```bash
# Install json-server
npm install -g json-server

# Create db.json
cat > db.json << EOF
{
  "register": {
    "status": "success",
    "message": "Registration successful",
    "accountId": "test-123"
  }
}
EOF

# Run server
json-server --watch db.json --port 8080
```

Then update `NetworkService.swift`:
```swift
private let baseURL = "http://localhost:8080"
```

**Option 2: Configure Real Backend**

Update your backend URL in `NetworkService.swift`:
```swift
private let baseURL = "https://your-backend-url.com"
```

### Add Push Notifications

1. **Add Capability**
   - Select target > Signing & Capabilities
   - Click + Capability
   - Add "Push Notifications"

2. **Create APNs Key**
   - Go to [developer.apple.com](https://developer.apple.com)
   - Certificates, Identifiers & Profiles > Keys
   - Create new key with APNs enabled
   - Download .p8 file

3. **Configure Backend**
   - Upload .p8 key to your backend
   - Configure with Key ID and Team ID

### Add Watch Complication

1. **Add Target** (if not already present)
   - File > New > Target
   - Watch Widget Extension
   - Name: "CloudCryptoComplication"

2. **Copy Complication Code**
   - The complication code is in `Complications/CloudCryptoComplication.swift`
   - Make sure it's included in the widget target

3. **Test Complication**
   - Run app on simulator or device
   - Long-press watch face
   - Edit > Add complication
   - Select Cloud Crypto

## 📱 Testing Scenarios

### Scenario 1: Happy Path Registration

```
1. Launch app
2. Tap REGISTER
3. Tap Generate
4. Verify serial number appears
5. Tap REGISTER
6. Wait for loading
7. See success message
8. Return to main screen
9. Verify serial number and date shown
```

### Scenario 2: Account Summary

```
1. Ensure device is registered
2. Tap ACCOUNT
3. Wait for loading
4. Verify balance displays
5. Check transaction stats
6. Verify device info
7. Tap BACK
```

### Scenario 3: Transfer

```
1. Ensure device is registered
2. Tap TRANSFER
3. Enter account ID: "test-account-123"
4. Enter amount: "100.00"
5. Tap SEND
6. Wait for loading
7. See success message
8. Return to main screen
```

### Scenario 4: Error Handling

```
1. Disconnect from internet (Airplane mode)
2. Try to register
3. Verify error message shown
4. Verify retry option available
5. Reconnect to internet
6. Tap retry
```

## 🐛 Troubleshooting

### Build Errors

**Problem**: "No signing certificate found"
```
Solution:
1. Xcode > Preferences > Accounts
2. Add Apple ID if not present
3. Download Manual Profiles
4. Or enable Automatic Signing
```

**Problem**: "Missing Info.plist"
```
Solution:
1. Ensure Info.plist is in project
2. Check target membership
3. Clean build folder (⌘⇧K)
```

### Runtime Issues

**Problem**: "App crashes on launch"
```
Solution:
1. Check Xcode console for error
2. Look for force-unwrapped nil values
3. Verify all files are in target
4. Clean and rebuild
```

**Problem**: "Network requests fail"
```
Solution:
1. Check URL is correct
2. Verify backend is running
3. Check App Transport Security settings
4. Test with Postman first
```

**Problem**: "Keychain errors"
```
Solution:
1. Delete app from simulator/device
2. Reinstall
3. Or reset simulator: Device > Erase All Content
```

## 📝 Code Examples

### Make a Custom Network Request

```swift
// In NetworkService
func customRequest() async throws -> CustomResponse {
    let request = CustomRequest(data: "value")
    let encoder = JSONEncoder()
    let body = try encoder.encode(request)
    
    return try await performRequest(
        endpoint: "/custom/endpoint",
        method: "POST",
        body: body
    )
}
```

### Add a New View

```swift
// 1. Create view file
struct NewView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            Text("New View")
            
            Button("Back", action: onBack)
        }
    }
}

// 2. Add to RegistrationUiState
enum RegistrationUiState: Equatable {
    // ... existing cases
    case newView
}

// 3. Add to ContentView switch
case .newView:
    NewView(onBack: { viewModel.loadMainScreen() })

// 4. Add ViewModel method
func showNewView() {
    uiState = .newView
}
```

### Add Local Storage

```swift
// In UserDefaultsManager
func saveCustomData(_ value: String) {
    defaults.set(value, forKey: "custom_key")
}

func loadCustomData() -> String? {
    return defaults.string(forKey: "custom_key")
}

// Usage in Repository
func saveData(_ value: String) {
    userDefaultsManager.saveCustomData(value)
}
```

## 🎨 Customization

### Change App Colors

```swift
// In any view
.buttonStyle(.borderedProminent)
.tint(.purple) // Change button color
```

### Change App Name

1. Select project in Xcode
2. Select target
3. Update "Display Name"
4. Or update Info.plist:
```xml
<key>CFBundleDisplayName</key>
<string>My Crypto</string>
```

### Add Loading Message

```swift
// In LoadingView.swift
VStack(spacing: 16) {
    ProgressView()
    Text("Please wait...")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

## 📊 Logging and Debugging

### Enable Console Logging

All network requests are logged:
```
📡 Request: POST https://fusio.callista.io/register
📤 Body: {"serialNumber":"ABC-123"}
📥 Response: 200
📥 Data: {"status":"success"}
```

### View Logs in Xcode

1. Run app
2. Open Console (⌘⇧C)
3. Filter by "CloudCrypto" or "📡"

### Debug Network Issues

```swift
// In NetworkService, add more logging
print("🔍 Request headers: \(request.allHTTPHeaderFields ?? [:])")
print("🔍 Response headers: \(httpResponse.allHeaderFields)")
```

### Debug State Changes

```swift
// In RegistrationViewModel, add logging
@Published var uiState: RegistrationUiState = .loading {
    didSet {
        print("🎯 State changed to: \(uiState)")
    }
}
```

## 🧪 Testing Tips

### Test Without Backend

Mock the repository:

```swift
class MockRegistrationRepository {
    func registerDevice(serialNumber: String, apnsToken: String?) async throws -> RegistrationResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return RegistrationResponse(
            status: "success",
            message: "Mock registration successful",
            registrationId: "mock-123",
            publicKey: nil,
            accountId: "mock-account",
            remainingBalance: 1000.0
        )
    }
}
```

### Test Error States

```swift
// In ViewModel, manually trigger errors
func testError() {
    uiState = .error(message: "This is a test error")
    toastMessage = "Test error message"
}
```

### Test Loading States

```swift
// In ViewModel
func testLoading() {
    uiState = .loading
    
    Task {
        try await Task.sleep(nanoseconds: 3_000_000_000)
        loadMainScreen()
    }
}
```

## 🎯 Next Steps

### Beginner

- [x] Run app in simulator
- [ ] Test all screens
- [ ] Modify button text
- [ ] Change colors
- [ ] Add logging

### Intermediate

- [ ] Configure backend
- [ ] Test on device
- [ ] Add push notifications
- [ ] Customize UI
- [ ] Add new screen

### Advanced

- [ ] Implement new feature
- [ ] Add unit tests
- [ ] Optimize performance
- [ ] Add analytics
- [ ] Prepare for App Store

## 📚 Additional Resources

- [README.md](../README.md) - Full project documentation
- [Architecture-Overview.md](Architecture-Overview.md) - Technical architecture
- [Setup-And-Deployment.md](Setup-And-Deployment.md) - Complete setup guide
- [InfoPlist-Configuration.md](InfoPlist-Configuration.md) - Configuration details

## 💡 Pro Tips

1. **Use Xcode Previews**: Test views instantly without running app
   ```swift
   #Preview {
       MainScreenView(...)
   }
   ```

2. **Use Breakpoints**: Debug issues by pausing execution
   - Click line number to add breakpoint
   - Run app and trigger code

3. **Use Print Debugging**: Add print statements liberally
   ```swift
   print("🔍 Serial number: \(serialNumber)")
   ```

4. **Clean Build Folder**: When things get weird
   - Press ⌘⇧K
   - Product > Clean Build Folder

5. **Reset Simulator**: For fresh start
   - Device > Erase All Content and Settings

## 🆘 Getting Help

1. **Check Console**: Most errors are logged there
2. **Read Error Messages**: They usually point to the problem
3. **Search Documentation**: This repo has extensive docs
4. **Check Apple Docs**: [developer.apple.com/documentation](https://developer.apple.com/documentation)
5. **Ask Questions**: Use GitHub issues or your team chat

## ✅ Pre-Deployment Checklist

Before submitting to App Store:

- [ ] All features tested on device
- [ ] No console errors
- [ ] App doesn't crash
- [ ] Network requests work
- [ ] Push notifications work (if enabled)
- [ ] Complications display correctly
- [ ] App icons added
- [ ] Version numbers updated
- [ ] Privacy policy created
- [ ] App Store screenshots prepared

## 🎉 Success!

You should now have a running watchOS cryptocurrency app! 

**What's Next?**
- Customize it to your needs
- Add your own features
- Deploy to App Store
- Share with users

---

Happy coding! 🚀

Last Updated: November 20, 2025
