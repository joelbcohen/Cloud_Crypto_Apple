<?php
/**
 * APNs Connection Test Script
 *
 * This script tests your connection to Apple's APNs servers
 * and helps diagnose HTTP/2 and network issues.
 *
 * Usage: php test-connection.php
 */

echo "========================================\n";
echo "APNs Connection Test\n";
echo "========================================\n\n";

// Test 1: Check HTTP/2 support
echo "1. Checking HTTP/2 support...\n";
$curlVersion = curl_version();
echo "   cURL version: {$curlVersion['version']}\n";

if (isset($curlVersion['features'])) {
    $http2Supported = ($curlVersion['features'] & CURL_VERSION_HTTP2) !== 0;
    if ($http2Supported) {
        echo "   ✓ HTTP/2 is supported\n";
    } else {
        echo "   ✗ HTTP/2 is NOT supported\n";
        echo "   ⚠️  You need to upgrade cURL or recompile PHP with HTTP/2 support\n";
    }
} else {
    echo "   ⚠️  Cannot determine HTTP/2 support\n";
}

if (defined('CURL_HTTP_VERSION_2_0')) {
    echo "   ✓ CURL_HTTP_VERSION_2_0 constant is defined\n";
} else {
    echo "   ✗ CURL_HTTP_VERSION_2_0 constant is NOT defined\n";
}
echo "\n";

// Test 2: Test basic HTTPS connectivity
echo "2. Testing basic HTTPS connectivity...\n";
$testUrls = [
    'https://www.apple.com' => 'Apple main site',
    'https://api.sandbox.push.apple.com' => 'APNs Sandbox',
    'https://api.push.apple.com' => 'APNs Production'
];

foreach ($testUrls as $url => $description) {
    echo "   Testing: $description ($url)\n";

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_CONNECTTIMEOUT => 5,
        CURLOPT_HEADER => false,
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_NOBODY => true  // HEAD request only
    ]);

    $result = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    $curlErrno = curl_errno($ch);

    if ($curlErrno) {
        echo "      ✗ Failed: ($curlErrno) $curlError\n";
    } else if ($httpCode == 0) {
        echo "      ✗ Failed: No response (HTTP Code 0)\n";
    } else if ($httpCode >= 200 && $httpCode < 500) {
        echo "      ✓ Success: HTTP $httpCode\n";
    } else {
        echo "      ⚠️  Unexpected HTTP Code: $httpCode\n";
    }

    curl_close($ch);
}
echo "\n";

// Test 3: Test HTTP/2 specifically with APNs
echo "3. Testing HTTP/2 connection to APNs...\n";
$apnsUrl = 'https://api.sandbox.push.apple.com';

$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL => $apnsUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT => 10,
    CURLOPT_CONNECTTIMEOUT => 5,
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
    CURLOPT_HEADER => true,
    CURLOPT_NOBODY => true,
    CURLOPT_SSL_VERIFYPEER => true
]);

$result = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
$curlErrno = curl_errno($ch);
$httpVersion = curl_getinfo($ch, CURLINFO_HTTP_VERSION);

echo "   URL: $apnsUrl\n";

if ($curlErrno) {
    echo "   ✗ Connection failed\n";
    echo "   Error ($curlErrno): $curlError\n";
    echo "\n   This is the same error preventing notifications from working!\n";
} else if ($httpCode == 0) {
    echo "   ✗ Connection failed (HTTP Code 0)\n";
    echo "   This means the connection couldn't be established.\n";
    if ($curlError) {
        echo "   cURL message: $curlError\n";
    }
} else {
    echo "   ✓ Connection successful\n";
    echo "   HTTP Code: $httpCode\n";

    // Decode HTTP version
    $versionNames = [
        CURL_HTTP_VERSION_1_0 => 'HTTP/1.0',
        CURL_HTTP_VERSION_1_1 => 'HTTP/1.1',
        CURL_HTTP_VERSION_2_0 => 'HTTP/2.0',
    ];
    $versionName = isset($versionNames[$httpVersion]) ? $versionNames[$httpVersion] : "Unknown ($httpVersion)";
    echo "   Protocol: $versionName\n";

    if ($httpVersion == CURL_HTTP_VERSION_2_0) {
        echo "   ✓ HTTP/2 is working!\n";
    } else {
        echo "   ⚠️  Not using HTTP/2 (using $versionName instead)\n";
        echo "   APNs requires HTTP/2 for the provider API\n";
    }
}

curl_close($ch);
echo "\n";

// Test 4: Try a mock APNs request (will fail auth, but tests connectivity)
echo "4. Testing mock APNs notification request...\n";
$testToken = str_repeat('0', 64); // Fake device token
$testUrl = "$apnsUrl/3/device/$testToken";

$payload = json_encode([
    'aps' => [
        'alert' => 'Test',
        'sound' => 'default'
    ]
]);

$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL => $testUrl,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $payload,
    CURLOPT_HTTPHEADER => [
        'authorization: bearer fake.jwt.token',
        'apns-topic: com.test.app',
        'content-type: application/json',
        'apns-push-type: alert'
    ],
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
    CURLOPT_HEADER => true,
    CURLOPT_TIMEOUT => 10,
    CURLOPT_CONNECTTIMEOUT => 5,
    CURLOPT_SSL_VERIFYPEER => true
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
$curlErrno = curl_errno($ch);

echo "   Test URL: $testUrl\n";

if ($curlErrno) {
    echo "   ✗ Request failed\n";
    echo "   Error ($curlErrno): $curlError\n";
    echo "\n   ⚠️  This is preventing your notifications from working!\n";
} else if ($httpCode == 0) {
    echo "   ✗ Request failed (HTTP Code 0)\n";
    echo "   The connection couldn't be established.\n";
} else {
    echo "   ✓ Request completed\n";
    echo "   HTTP Code: $httpCode\n";

    // We expect 403 (bad auth) or 400 (bad request), which is fine
    if ($httpCode == 403) {
        echo "   ✓ Got 403 (authentication failed) - this is expected!\n";
        echo "   The connection is working! The 403 is because we used a fake JWT.\n";
    } else if ($httpCode == 400) {
        echo "   ✓ Got 400 (bad request) - this is expected!\n";
        echo "   The connection is working! The 400 is because we used a fake token.\n";
    } else if ($httpCode == 405) {
        echo "   ✓ Got 405 (method not allowed) - connection works!\n";
    } else {
        echo "   Got HTTP $httpCode\n";
    }
}

curl_close($ch);
echo "\n";

// Summary
echo "========================================\n";
echo "Summary & Recommendations\n";
echo "========================================\n\n";

echo "If you see connection failures above:\n";
echo "1. Check your internet connection\n";
echo "2. Check if a firewall is blocking HTTPS connections\n";
echo "3. Verify HTTP/2 support: run 'curl --version' in terminal\n";
echo "4. If using a proxy, configure cURL proxy settings\n\n";

echo "If HTTP/2 is not supported:\n";
echo "- On macOS: brew upgrade curl\n";
echo "- Update PHP to a version with HTTP/2 support\n";
echo "- Ensure cURL was compiled with nghttp2\n\n";

echo "For detailed PHP/cURL info, run: php -i | grep -i curl\n";
