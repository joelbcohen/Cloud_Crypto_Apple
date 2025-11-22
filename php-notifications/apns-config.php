<?php
/**
 * APNs Configuration
 *
 * This file contains the configuration for sending APNs notifications.
 * You need to obtain these values from your Apple Developer account.
 */

return [
    // Your Apple Developer Team ID
    // Find it at: https://developer.apple.com/account/#/membership
    'team_id' => 'YOUR_TEAM_ID_HERE',

    // Your APNs Key ID
    // This is the Key ID of the .p8 file you downloaded from Apple Developer Portal
    'key_id' => 'YOUR_KEY_ID_HERE',

    // Your app's Bundle ID
    // This should match the bundle ID in your Xcode project
    // Example: com.yourcompany.cloudcrypto.watchkitapp
    'bundle_id' => 'YOUR_BUNDLE_ID_HERE',

    // Path to your .p8 auth key file
    // Download from: https://developer.apple.com/account/resources/authkeys/list
    // Keep this file secure and never commit it to version control!
    'auth_key_path' => __DIR__ . '/AuthKey_XXXXXXXXXX.p8',

    // Use sandbox environment (true) or production (false)
    // Set to true for development/testing, false for production
    'use_sandbox' => true,
];
