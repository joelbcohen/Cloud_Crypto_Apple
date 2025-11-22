# APNs Notifications for Apple Watch

This directory contains PHP code for sending push notifications to Apple Watch devices using the modern HTTP/2 APNs API with token-based authentication.

## Overview

The solution consists of:

- `APNsNotificationSender.php` - Main class for sending notifications
- `apns-config.php` - Configuration file for APNs credentials
- `send-notification.php` - Example usage script
- `README.md` - This file

## Prerequisites

- PHP 7.0 or higher
- cURL extension with HTTP/2 support
- OpenSSL extension
- APNs authentication key (.p8 file) from Apple Developer Portal
- Apple Developer Team ID
- App Bundle ID

## Setup Instructions

### 1. Generate APNs Authentication Key

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Click the "+" button to create a new key
3. Give it a name (e.g., "Cloud Crypto APNs Key")
4. Check "Apple Push Notifications service (APNs)"
5. Click "Continue" and then "Register"
6. Download the `.p8` file (you can only download it once!)
7. Note the Key ID (e.g., "ABC123XYZ")

### 2. Find Your Team ID

1. Go to [Apple Developer Membership](https://developer.apple.com/account/#/membership)
2. Your Team ID is displayed on this page (e.g., "DEF456UVW")

### 3. Configure the PHP Script

1. Copy the `.p8` file to the `php-notifications` directory
2. Edit `apns-config.php` and fill in:
   - `team_id` - Your Team ID from step 2
   - `key_id` - Your Key ID from step 1
   - `bundle_id` - Your app's bundle identifier (check Xcode project)
   - `auth_key_path` - Path to your .p8 file
   - `use_sandbox` - Set to `true` for testing, `false` for production

Example configuration:

```php
return [
    'team_id' => 'DEF456UVW',
    'key_id' => 'ABC123XYZ',
    'bundle_id' => 'com.yourcompany.cloudcrypto.watchkitapp',
    'auth_key_path' => __DIR__ . '/AuthKey_ABC123XYZ.p8',
    'use_sandbox' => true,
];
```

### 4. Verify Your Setup

Before sending notifications, run the diagnostic scripts to verify everything is configured correctly:

```bash
# Check configuration and find .p8 files
php check-setup.php

# Test network connectivity and HTTP/2 support
php test-connection.php
```

The `test-connection.php` script will diagnose common issues like:
- Missing HTTP/2 support
- Network connectivity problems
- Firewall blocking
- SSL/TLS configuration issues

**Important**: If you get "HTTP Code 0" errors, it means the connection to Apple's servers is failing. Run `test-connection.php` to diagnose the issue.

### 5. Get Device Tokens

Device tokens (stored as `fcmToken` in your database) are obtained when users register their Apple Watch. These tokens are sent to your server during the registration process.

You can find the device token in:
- Your registration database/API
- The `fcmToken` field from `RegistrationRequest`

## Usage

### Basic Example

```php
require_once 'APNsNotificationSender.php';

$config = require 'apns-config.php';

// Initialize sender
$sender = new APNsNotificationSender(
    $config['team_id'],
    $config['key_id'],
    $config['bundle_id'],
    $config['auth_key_path'],
    $config['use_sandbox']
);

// Build notification
$notification = APNsNotificationSender::buildAlertNotification(
    'Hello Watch!',
    'This is a test notification',
    [
        'type' => 'test',
        'message' => 'Custom data here'
    ]
);

// Send notification
$result = $sender->sendNotification($deviceToken, $notification);

if ($result['success']) {
    echo "Notification sent! ID: " . $result['apnsId'];
} else {
    echo "Failed: " . json_encode($result['error']);
}
```

### Running the Example Script

```bash
cd php-notifications
php send-notification.php
```

Make sure to edit `send-notification.php` and replace `YOUR_DEVICE_TOKEN_HERE` with an actual device token from your database.

## Notification Types

Based on your `APNsService.swift`, the app handles these notification types:

### 1. Registration Update

```php
$notification = APNsNotificationSender::buildAlertNotification(
    'Registration Updated',
    'Your device registration has been updated',
    [
        'type' => 'registration_update',
        'message' => 'Registration confirmed'
    ]
);
```

### 2. Config Update

```php
$notification = APNsNotificationSender::buildAlertNotification(
    'Configuration Updated',
    'New settings available',
    [
        'type' => 'config_update',
        'message' => 'Configuration synced'
    ]
);
```

### 3. Status Update

```php
$notification = APNsNotificationSender::buildAlertNotification(
    'Status Update',
    'Your account status has changed',
    [
        'type' => 'status_update',
        'message' => 'Status updated'
    ]
);
```

### 4. Silent Notification (Background Update)

```php
$notification = APNsNotificationSender::buildSilentNotification([
    'type' => 'status_update',
    'message' => 'Background sync',
    'updateType' => 'balance'
]);

$sender->sendNotification($deviceToken, $notification, [
    'pushType' => 'background',
    'priority' => 5
]);
```

## Integration with Your Registration System

Assuming you have a database table storing registered devices:

```php
// Example: Send notification to all registered devices
$pdo = new PDO('mysql:host=localhost;dbname=yourdb', 'user', 'pass');
$stmt = $pdo->query("SELECT fcmToken FROM devices WHERE fcmToken IS NOT NULL");

$deviceTokens = $stmt->fetchAll(PDO::FETCH_COLUMN);

$notification = APNsNotificationSender::buildAlertNotification(
    'System Alert',
    'Important update available',
    ['type' => 'status_update', 'message' => 'Update available']
);

$results = $sender->sendBulkNotifications($deviceTokens, $notification);

// Process results
foreach ($results as $result) {
    if (!$result['success']) {
        // Log failed sends or remove invalid tokens
        error_log("Failed to send to {$result['deviceToken']}");
    }
}
```

## API Reference

### APNsNotificationSender Methods

#### `sendNotification($deviceToken, $notification, $options = [])`

Send a notification to a single device.

**Parameters:**
- `$deviceToken` - The APNs device token (fcmToken from registration)
- `$notification` - Notification payload array
- `$options` - Optional parameters:
  - `priority` - 10 (high) or 5 (low)
  - `expiration` - Unix timestamp when notification expires
  - `collapseId` - Identifier for collapsing similar notifications
  - `pushType` - 'alert', 'background', or 'voip'

**Returns:** Array with keys:
- `success` - Boolean indicating success
- `httpCode` - HTTP status code
- `apnsId` - Unique notification identifier
- `deviceToken` - The device token used
- `error` - Error details (if failed)

#### `sendBulkNotifications($deviceTokens, $notification, $options = [])`

Send the same notification to multiple devices.

**Parameters:**
- `$deviceTokens` - Array of device tokens
- `$notification` - Notification payload
- `$options` - Optional parameters (same as sendNotification)

**Returns:** Array of results (one per device)

#### `buildAlertNotification($title, $body, $customData = [])`

Build an alert notification payload.

**Parameters:**
- `$title` - Notification title
- `$body` - Notification body
- `$customData` - Additional custom data (type, message, etc.)

**Returns:** Notification payload array

#### `buildSilentNotification($customData = [])`

Build a silent notification for background updates.

**Parameters:**
- `$customData` - Custom data to include

**Returns:** Notification payload array

## Testing

### Using Sandbox Environment

During development, use the sandbox environment:

```php
'use_sandbox' => true
```

Build your app with a development provisioning profile and install on a real device (notifications don't work in the simulator).

### Using Production Environment

For production:

```php
'use_sandbox' => false
```

Build your app with a production provisioning profile.

### Common Error Codes

- `400 BadDeviceToken` - The device token is invalid
- `403 InvalidProviderToken` - Your JWT or APNs key is invalid
- `410 Unregistered` - The device token is no longer valid (user uninstalled app)
- `413 PayloadTooLarge` - Notification payload exceeds 4KB limit
- `429 TooManyRequests` - You're sending too many notifications
- `500 InternalServerError` - APNs server error (retry)
- `503 ServiceUnavailable` - APNs temporarily unavailable (retry)

## Security Considerations

1. **Keep your .p8 file secure!** Never commit it to version control
2. Add `*.p8` to your `.gitignore` file
3. Store the file with restricted permissions (chmod 600)
4. Use environment variables for sensitive configuration in production
5. Implement rate limiting to prevent abuse
6. Validate device tokens before sending

## Production Deployment

For production use:

1. Use environment variables for configuration:
   ```php
   $config = [
       'team_id' => getenv('APNS_TEAM_ID'),
       'key_id' => getenv('APNS_KEY_ID'),
       'bundle_id' => getenv('APNS_BUNDLE_ID'),
       'auth_key_path' => getenv('APNS_KEY_PATH'),
       'use_sandbox' => false
   ];
   ```

2. Implement error logging and monitoring
3. Queue notifications for better performance (use Redis, RabbitMQ, etc.)
4. Handle failed tokens (remove from database after 410 errors)
5. Implement retry logic for temporary failures (500, 503 errors)

## Troubleshooting

### HTTP Code 0 / Connection Failed

If you get "HTTP Code 0" errors, this means PHP cannot connect to Apple's APNs servers. Run the diagnostic:

```bash
php test-connection.php
```

Common causes:
1. **Missing HTTP/2 support** - APNs requires HTTP/2
   - Check: `curl --version | grep HTTP2`
   - Fix (macOS): `brew upgrade curl && brew reinstall php`
   - The output should show "HTTP2" in features

2. **Network/Firewall blocking**
   - Ensure you can reach `https://api.sandbox.push.apple.com`
   - Check firewall settings
   - Try: `curl -v https://api.sandbox.push.apple.com`

3. **cURL/OpenSSL version too old**
   - Update cURL to latest version
   - Ensure OpenSSL 1.0.2+ is installed
   - Check: `php -i | grep -i curl`

4. **PHP compiled without HTTP/2**
   - You may need to recompile PHP with `--with-curl` using a newer libcurl
   - Or use a different PHP installation (like from Homebrew on macOS)

### "Failed to load auth key"
- Check the path to your .p8 file
- Verify file permissions (readable by PHP process)

### "BadDeviceToken" error
- Ensure you're using the correct environment (sandbox vs production)
- Verify the device token is valid and correctly formatted
- Check that the device token matches the app bundle ID

### "InvalidProviderToken" error
- Verify your Team ID and Key ID are correct
- Ensure the .p8 file is valid
- Check that the APNs key has push notification permissions

### Notifications not appearing on watch
- Verify the app has notification permissions
- Check that the bundle ID matches
- Ensure the watch is paired and unlocked
- Test with a visible notification first (not silent)

## Resources

- [APNs Provider API Documentation](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)
- [APNs Authentication Token](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns)
- [Payload Key Reference](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)

## License

This code is provided as-is for use with the Cloud Crypto Watch App.
