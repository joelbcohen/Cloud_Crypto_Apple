<?php
/**
 * Example script for sending APNs notifications to Apple Watch
 *
 * Usage: php send-notification.php
 */

require_once __DIR__ . '/APNsNotificationSender.php';

// Load configuration
$config = require __DIR__ . '/apns-config.php';

// Initialize the notification sender
try {
    $sender = new APNsNotificationSender(
        $config['team_id'],
        $config['key_id'],
        $config['bundle_id'],
        $config['auth_key_path'],
        $config['use_sandbox']
    );

    echo "APNs Notification Sender initialized successfully\n";
    echo "Environment: " . ($config['use_sandbox'] ? 'Sandbox' : 'Production') . "\n\n";

} catch (Exception $e) {
    die("Failed to initialize sender: " . $e->getMessage() . "\n");
}

// ========================================
// Example 1: Send a simple alert notification
// ========================================

echo "=== Example 1: Simple Alert Notification ===\n";

// Replace with actual device token from your database
// This is the fcmToken you received during device registration
$deviceToken = 'YOUR_DEVICE_TOKEN_HERE';

// Build notification payload
$notification = APNsNotificationSender::buildAlertNotification(
    'Cloud Crypto Alert',
    'Your account balance has been updated!',
    [
        'type' => 'balance_update',
        'message' => 'Account credited with 100 tokens',
        'accountId' => '12345'
    ]
);

echo "Sending notification to: " . substr($deviceToken, 0, 20) . "...\n";
echo "Payload: " . json_encode($notification, JSON_PRETTY_PRINT) . "\n";

try {
    $result = $sender->sendNotification($deviceToken, $notification);

    if ($result['success']) {
        echo "✓ Notification sent successfully!\n";
        echo "APNs ID: " . $result['apnsId'] . "\n";
    } else {
        echo "✗ Failed to send notification\n";
        echo "HTTP Code: " . $result['httpCode'] . "\n";
        echo "Error: " . json_encode($result['error'], JSON_PRETTY_PRINT) . "\n";
    }
} catch (Exception $e) {
    echo "✗ Exception: " . $e->getMessage() . "\n";
}

echo "\n";

// ========================================
// Example 2: Send notification with custom data matching your APNsService
// ========================================

echo "=== Example 2: Registration Update Notification ===\n";

$notification = APNsNotificationSender::buildAlertNotification(
    'Registration Status',
    'Your device registration has been updated',
    [
        'type' => 'registration_update',
        'message' => 'Registration confirmed',
        'accountId' => '12345'
    ]
);

echo "Payload: " . json_encode($notification, JSON_PRETTY_PRINT) . "\n";

try {
    $result = $sender->sendNotification($deviceToken, $notification);

    if ($result['success']) {
        echo "✓ Notification sent successfully!\n";
        echo "APNs ID: " . $result['apnsId'] . "\n";
    } else {
        echo "✗ Failed to send notification\n";
        echo "HTTP Code: " . $result['httpCode'] . "\n";
        echo "Error: " . json_encode($result['error'], JSON_PRETTY_PRINT) . "\n";
    }
} catch (Exception $e) {
    echo "✗ Exception: " . $e->getMessage() . "\n";
}

echo "\n";

// ========================================
// Example 3: Send silent notification for background update
// ========================================

echo "=== Example 3: Silent Background Notification ===\n";

$notification = APNsNotificationSender::buildSilentNotification([
    'type' => 'status_update',
    'message' => 'Background sync',
    'updateType' => 'account_balance'
]);

echo "Payload: " . json_encode($notification, JSON_PRETTY_PRINT) . "\n";

try {
    $result = $sender->sendNotification($deviceToken, $notification, [
        'priority' => 5,  // Lower priority for background updates
        'pushType' => 'background'
    ]);

    if ($result['success']) {
        echo "✓ Silent notification sent successfully!\n";
        echo "APNs ID: " . $result['apnsId'] . "\n";
    } else {
        echo "✗ Failed to send notification\n";
        echo "HTTP Code: " . $result['httpCode'] . "\n";
        echo "Error: " . json_encode($result['error'], JSON_PRETTY_PRINT) . "\n";
    }
} catch (Exception $e) {
    echo "✗ Exception: " . $e->getMessage() . "\n";
}

echo "\n";

// ========================================
// Example 4: Send to multiple devices
// ========================================

echo "=== Example 4: Bulk Notification ===\n";

$deviceTokens = [
    'DEVICE_TOKEN_1',
    'DEVICE_TOKEN_2',
    'DEVICE_TOKEN_3'
];

$notification = APNsNotificationSender::buildAlertNotification(
    'System Alert',
    'Important update for all users',
    [
        'type' => 'config_update',
        'message' => 'System maintenance completed'
    ]
);

echo "Sending to " . count($deviceTokens) . " devices...\n";

try {
    $results = $sender->sendBulkNotifications($deviceTokens, $notification);

    $successCount = 0;
    $failureCount = 0;

    foreach ($results as $result) {
        if ($result['success']) {
            $successCount++;
            echo "  ✓ " . substr($result['deviceToken'], 0, 20) . "... - Success\n";
        } else {
            $failureCount++;
            echo "  ✗ " . substr($result['deviceToken'], 0, 20) . "... - Failed\n";
        }
    }

    echo "\nSummary: $successCount succeeded, $failureCount failed\n";

} catch (Exception $e) {
    echo "✗ Exception: " . $e->getMessage() . "\n";
}

echo "\n";
echo "=== All examples completed ===\n";
