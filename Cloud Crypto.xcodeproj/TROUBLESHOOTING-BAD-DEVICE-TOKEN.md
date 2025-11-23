# Troubleshooting: "Bad Device Token" on Physical Apple Watch

## Problem
Getting "Bad device token" error when the app runs on a physical Apple Watch.

## Root Cause
The device token is valid, but the **backend server is using the wrong APNs endpoint** for the token's environment.

---

## Understanding APNs Environments

Apple has TWO separate push notification servers:

| Environment | APNs Server URL | When Used |
|-------------|----------------|-----------|
| **Sandbox** | `https://api.sandbox.push.apple.com` | Development builds from Xcode |
| **Production** | `https://api.push.apple.com` | TestFlight & App Store builds |

**Critical:** Device tokens are environment-specific. A sandbox token will NOT work on production servers and vice versa.

---

## How Your App Handles This

Your app already detects the environment correctly:

### 1. Token Generation
When APNs generates a token, your app detects the environment:

```swift
// In APNsService.swift
static func detectAPNsEnvironment() -> APNsEnvironment {
    #if DEBUG
    return .sandbox  // ✅ Debug builds = sandbox
    #else
    // Production logic here
    return .production
    #endif
}
```

### 2. Token Storage
The environment is stored along with the token:

```swift
// In APNsService.swift
func setDeviceToken(_ tokenData: Data) {
    self.deviceToken = token
    self.tokenEnvironment = Self.detectAPNsEnvironment()
    // tokenEnvironment is now "sandbox" or "production"
}
```

### 3. Sent to Backend
Both the token AND environment are sent to your backend:

```swift
// In RegistrationRepository.swift
let request = RegistrationRequest(
    serialNumber: serialNumber,
    fcmToken: apnsToken,              // ← The device token
    apnsEnvironment: apnsEnvironment,  // ← "sandbox" or "production"
    // ... other fields
)
```

---

## The Problem: Backend Not Using Environment

Your backend receives the `apnsEnvironment` field but might be:

❌ **Ignoring it** and always using the same endpoint
❌ **Misconfigured** to use the wrong endpoint
❌ **Not passing it** to the APNs client library

---

## Solution: Fix Backend Configuration

### Option A: Backend Auto-Selects Endpoint (Recommended)

Your backend should read the `apnsEnvironment` field and select the correct APNs server:

**Pseudo-code:**
```python
def send_push_notification(device_token, apns_environment, message):
    if apns_environment == "sandbox":
        apns_url = "https://api.sandbox.push.apple.com"
    elif apns_environment == "production":
        apns_url = "https://api.push.apple.com"
    else:
        # Default to sandbox for safety
        apns_url = "https://api.sandbox.push.apple.com"
    
    # Send notification to the selected server
    send_to_apns(apns_url, device_token, message)
```

**Example with node-apn library (Node.js):**
```javascript
const apn = require('apn');

function sendPushNotification(deviceToken, apnsEnvironment, message) {
    const options = {
        token: {
            key: "path/to/APNsAuthKey.p8",
            keyId: "YOUR_KEY_ID",
            teamId: "YOUR_TEAM_ID"
        },
        production: apnsEnvironment === "production"  // ✅ Key line!
    };
    
    const apnProvider = new apn.Provider(options);
    
    const notification = new apn.Notification();
    notification.alert = message;
    notification.topic = "com.yourcompany.cloudcrypto.watchapp";
    
    apnProvider.send(notification, deviceToken).then((result) => {
        console.log("Sent:", result);
    });
}
```

**Example with pushy library (Python):**
```python
from pushy import APNs

def send_push_notification(device_token, apns_environment, message):
    use_sandbox = (apns_environment == "sandbox")
    
    apns = APNs(
        key='path/to/APNsAuthKey.p8',
        key_id='YOUR_KEY_ID',
        team_id='YOUR_TEAM_ID',
        use_sandbox=use_sandbox  # ✅ Key parameter!
    )
    
    apns.send_notification(device_token, message)
```

---

### Option B: Separate Tokens for Each Environment

Store device tokens separately for each environment:

**Database Schema:**
```sql
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY,
    serial_number VARCHAR(255),
    apns_token_sandbox VARCHAR(255),
    apns_token_production VARCHAR(255),
    updated_at TIMESTAMP
);
```

**Backend Logic:**
```python
def register_device(serial_number, fcm_token, apns_environment):
    if apns_environment == "sandbox":
        db.update(serial_number, apns_token_sandbox=fcm_token)
    else:
        db.update(serial_number, apns_token_production=fcm_token)

def send_notification(serial_number):
    tokens = db.get_tokens(serial_number)
    
    # Try production first
    if tokens.apns_token_production:
        send_to_production(tokens.apns_token_production)
    
    # Fallback to sandbox
    if tokens.apns_token_sandbox:
        send_to_sandbox(tokens.apns_token_sandbox)
```

---

## Verification Steps

### Step 1: Check Logs in Xcode

When you run the app on your physical watch, you should see:

```
🔵 [APNsService.setDeviceToken] Environment: sandbox
📱 Device Token: a1b2c3d4e5f6...
🔧 [Repository] apnsEnvironment: sandbox
```

**Confirm:** The environment is detected as **"sandbox"** when running from Xcode.

---

### Step 2: Verify Backend Receives Environment

Add logging to your backend when it receives the registration request:

```
Received registration:
  - serialNumber: WATCH-12345
  - fcmToken: a1b2c3d4e5f6...
  - apnsEnvironment: sandbox  ← Check this!
```

**Confirm:** The backend is receiving the `apnsEnvironment` field.

---

### Step 3: Verify Backend Uses Correct Server

When your backend sends a test notification, log which server it's using:

```
Sending push notification:
  - Device token: a1b2c3d4e5f6...
  - APNs server: https://api.sandbox.push.apple.com  ← Check this!
  - Topic: com.yourcompany.cloudcrypto.watchapp
```

**Confirm:** The server matches the environment (sandbox for Xcode builds).

---

### Step 4: Test with APNs Tool

Use a tool like [Knuff](https://github.com/KnuffApp/Knuff) or [APNS-Tool](https://github.com/onmyway133/PushNotifications) to send test notifications:

1. Select **Sandbox** environment
2. Enter your device token
3. Enter your bundle ID: `com.yourcompany.cloudcrypto.watchapp`
4. Send a test notification

**If this works:** Your token is valid, the problem is your backend.
**If this fails:** Your APNs certificate/key might be invalid.

---

## Testing Production Environment

To test the production environment without releasing to the App Store:

### Option 1: TestFlight
1. Archive your app in Xcode
2. Upload to App Store Connect
3. Add yourself as a tester in TestFlight
4. Install via TestFlight
5. The token will now be a **production** token

### Option 2: Ad Hoc Distribution
1. Create an Ad Hoc provisioning profile
2. Enable production APNs in the profile
3. Build and install with this profile
4. The token will be a **production** token

---

## Common Mistakes

### ❌ Mistake 1: Hardcoded Environment
```python
# BAD: Always uses production
apns = APNs(use_sandbox=False)
```

```python
# GOOD: Uses environment from request
apns = APNs(use_sandbox=(environment == "sandbox"))
```

### ❌ Mistake 2: Ignoring apnsEnvironment Field
```python
# BAD: Field is received but not used
def register_device(serial_number, fcm_token, apns_environment):
    db.save(serial_number, fcm_token)
    # apns_environment is ignored!
```

```python
# GOOD: Field is stored and used
def register_device(serial_number, fcm_token, apns_environment):
    db.save(serial_number, fcm_token, apns_environment)
```

### ❌ Mistake 3: Wrong APNs Certificate
- Using a **production certificate** with **sandbox tokens**
- Using an **expired certificate**
- Using a certificate for the **wrong bundle ID**

**Solution:** Use an APNs auth key (.p8 file) instead of certificates. Auth keys work for both environments and never expire.

---

## Quick Fix Checklist

- [ ] Backend receives `apnsEnvironment` field
- [ ] Backend logs the environment value
- [ ] Backend selects correct APNs server based on environment
- [ ] APNs auth key (.p8) is valid and not expired
- [ ] Team ID matches your Apple Developer account
- [ ] Key ID matches the APNs key in Apple Developer portal
- [ ] Bundle ID matches exactly: `com.yourcompany.cloudcrypto.watchapp`
- [ ] Token is not empty or nil when sent to backend
- [ ] Backend is not modifying or truncating the token

---

## Debug Commands

### Check your APNs configuration on Apple Developer portal:
```bash
# Go to: https://developer.apple.com/account/resources/authkeys/list
# Verify your APNs key exists and note the Key ID
```

### Test sending notification with curl:
```bash
# 1. Generate JWT token (required for APNs)
# Use a tool like: https://jwt.io or a script

# 2. Send notification to SANDBOX
curl -v \
  --header "apns-topic: com.yourcompany.cloudcrypto.watchapp" \
  --header "apns-push-type: alert" \
  --header "authorization: bearer YOUR_JWT_TOKEN" \
  --data '{"aps":{"alert":"Test from sandbox"}}' \
  --http2 \
  https://api.sandbox.push.apple.com/3/device/YOUR_DEVICE_TOKEN

# 3. Check response:
# - 200 OK = Success
# - 400 BadDeviceToken = Wrong environment or invalid token
# - 403 Forbidden = Certificate/key issue
```

---

## When in Doubt

If you're still getting "Bad device token":

1. **Enable verbose logging** on your backend
2. **Capture the exact error** from APNs (it includes reason)
3. **Share the logs** with your backend team
4. **Verify the token** is the same from app to backend to APNs

The APNs server returns specific error codes:

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `BadDeviceToken` | Token format invalid OR wrong environment | Check environment |
| `Unregistered` | Token is no longer valid | Device uninstalled app |
| `TopicDisallowed` | Bundle ID mismatch | Fix bundle ID in backend |
| `InvalidProviderToken` | JWT token invalid | Regenerate JWT with correct key |

---

## Additional Resources

- [Apple: Communicating with APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)
- [Apple: Establishing a Token-Based Connection to APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns)
- [APNs HTTP/2 API](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)

---

## Summary

**The Issue:** "Bad device token" means the backend is using the wrong APNs server for your token.

**The Solution:** Make sure your backend reads the `apnsEnvironment` field and uses:
- `api.sandbox.push.apple.com` for `"sandbox"`
- `api.push.apple.com` for `"production"`

**Your app is already doing everything correctly!** The fix needs to be on the backend side.

---

Last Updated: November 22, 2025
