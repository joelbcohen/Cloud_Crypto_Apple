<?php
/**
 * APNs Setup Diagnostic Tool
 *
 * Run this script to verify your APNs configuration before sending notifications
 *
 * Usage: php check-setup.php
 */

echo "========================================\n";
echo "APNs Configuration Diagnostic Tool\n";
echo "========================================\n\n";

// Check PHP version
echo "1. Checking PHP version...\n";
$phpVersion = phpversion();
echo "   PHP Version: $phpVersion\n";
if (version_compare($phpVersion, '7.0.0', '<')) {
    echo "   ⚠️  WARNING: PHP 7.0 or higher is recommended\n";
} else {
    echo "   ✓ PHP version OK\n";
}
echo "\n";

// Check required extensions
echo "2. Checking required PHP extensions...\n";
$requiredExtensions = ['curl', 'openssl', 'json'];
$missingExtensions = [];

foreach ($requiredExtensions as $ext) {
    if (extension_loaded($ext)) {
        echo "   ✓ $ext extension loaded\n";
    } else {
        echo "   ✗ $ext extension NOT loaded\n";
        $missingExtensions[] = $ext;
    }
}

if (!empty($missingExtensions)) {
    echo "\n   ⚠️  ERROR: Missing extensions: " . implode(', ', $missingExtensions) . "\n";
    echo "   Install them and try again.\n";
    exit(1);
}
echo "\n";

// Check cURL HTTP/2 support
echo "3. Checking cURL HTTP/2 support...\n";
$curlVersion = curl_version();
echo "   cURL Version: {$curlVersion['version']}\n";
if (defined('CURL_HTTP_VERSION_2_0')) {
    echo "   ✓ HTTP/2 support available\n";
} else {
    echo "   ✗ HTTP/2 support NOT available\n";
    echo "   ⚠️  You may need to upgrade cURL\n";
}
echo "\n";

// Find .p8 files in current directory
echo "4. Looking for .p8 files in current directory...\n";
$currentDir = __DIR__;
echo "   Current directory: $currentDir\n";

$p8Files = glob($currentDir . '/*.p8');
if (!empty($p8Files)) {
    echo "   ✓ Found " . count($p8Files) . " .p8 file(s):\n";
    foreach ($p8Files as $file) {
        $basename = basename($file);
        $size = filesize($file);
        $readable = is_readable($file) ? 'readable' : 'NOT readable';
        echo "      - $basename ($size bytes, $readable)\n";

        // Try to extract Key ID from filename
        if (preg_match('/AuthKey_([A-Z0-9]+)\.p8/', $basename, $matches)) {
            echo "        Detected Key ID: {$matches[1]}\n";
        }
    }
} else {
    echo "   ⚠️  No .p8 files found in current directory\n";
    echo "   Please download your APNs auth key from:\n";
    echo "   https://developer.apple.com/account/resources/authkeys/list\n";
}
echo "\n";

// Load and check configuration
echo "5. Checking configuration file...\n";
$configFile = $currentDir . '/apns-config.php';

if (!file_exists($configFile)) {
    echo "   ✗ Configuration file not found: $configFile\n";
    exit(1);
}

echo "   ✓ Configuration file found\n";
$config = require $configFile;

$configKeys = ['team_id', 'key_id', 'bundle_id', 'auth_key_path', 'use_sandbox'];
$configOk = true;

foreach ($configKeys as $key) {
    if (!isset($config[$key])) {
        echo "   ✗ Missing config key: $key\n";
        $configOk = false;
    } else {
        $value = $config[$key];

        // Don't show full values for security
        if (is_bool($value)) {
            $displayValue = $value ? 'true' : 'false';
        } else if (strlen($value) > 50) {
            $displayValue = substr($value, 0, 47) . '...';
        } else {
            $displayValue = $value;
        }

        // Check for placeholder values
        if (strpos($value, 'YOUR_') !== false || strpos($value, 'XXXXXXXXXX') !== false) {
            echo "   ⚠️  $key: $displayValue (PLACEHOLDER - needs to be updated)\n";
            $configOk = false;
        } else {
            echo "   ✓ $key: $displayValue\n";
        }
    }
}
echo "\n";

// Check auth key file specifically
echo "6. Verifying auth key file...\n";
if (isset($config['auth_key_path'])) {
    $authKeyPath = $config['auth_key_path'];
    echo "   Configured path: $authKeyPath\n";

    // Expand __DIR__ if present
    if (strpos($authKeyPath, '__DIR__') !== false) {
        echo "   ⚠️  Note: __DIR__ in path will be evaluated when config is loaded\n";
        $authKeyPath = str_replace('__DIR__', $currentDir, $authKeyPath);
        echo "   Expanded path: $authKeyPath\n";
    }

    if (file_exists($authKeyPath)) {
        echo "   ✓ Auth key file exists\n";

        if (is_readable($authKeyPath)) {
            echo "   ✓ Auth key file is readable\n";

            // Read and validate file content
            $content = file_get_contents($authKeyPath);
            if (strpos($content, '-----BEGIN PRIVATE KEY-----') !== false) {
                echo "   ✓ Auth key file appears to be valid (contains private key header)\n";
            } else {
                echo "   ✗ Auth key file doesn't appear to be a valid .p8 file\n";
                $configOk = false;
            }
        } else {
            echo "   ✗ Auth key file is NOT readable (check permissions)\n";
            $configOk = false;
        }
    } else {
        echo "   ✗ Auth key file NOT FOUND at: $authKeyPath\n";
        echo "\n   Troubleshooting:\n";
        echo "   - Check if the file exists\n";
        echo "   - Verify the filename (should be like: AuthKey_ABC123XYZ.p8)\n";
        echo "   - Check the path in apns-config.php\n";

        if (!empty($p8Files)) {
            echo "\n   Found these .p8 files instead:\n";
            foreach ($p8Files as $file) {
                echo "      - " . basename($file) . "\n";
            }
            echo "\n   Update apns-config.php to use one of these files.\n";
        }
        $configOk = false;
    }
}
echo "\n";

// Final summary
echo "========================================\n";
echo "Summary\n";
echo "========================================\n";

if ($configOk) {
    echo "✓ Configuration looks good!\n";
    echo "You should be able to send notifications now.\n";
    echo "\nTry running: php send-notification.php\n";
} else {
    echo "⚠️  Configuration needs attention\n";
    echo "Please fix the issues above and run this script again.\n";
    exit(1);
}
