<?php
/**
 * APNs Notification Sender for Apple Watch
 *
 * This class handles sending push notifications to Apple devices using
 * the modern HTTP/2 APNs API with token-based authentication.
 */
class APNsNotificationSender {

    private $teamId;
    private $keyId;
    private $bundleId;
    private $authKeyPath;
    private $useSandbox;
    private $jwt;
    private $jwtExpiry;

    /**
     * Constructor
     *
     * @param string $teamId Your Apple Developer Team ID
     * @param string $keyId Your APNs Key ID
     * @param string $bundleId Your app's bundle identifier
     * @param string $authKeyPath Path to your .p8 auth key file
     * @param bool $useSandbox Use sandbox environment (default: true)
     */
    public function __construct($teamId, $keyId, $bundleId, $authKeyPath, $useSandbox = true) {
        $this->teamId = $teamId;
        $this->keyId = $keyId;
        $this->bundleId = $bundleId;
        $this->authKeyPath = $authKeyPath;
        $this->useSandbox = $useSandbox;
        $this->jwt = null;
        $this->jwtExpiry = 0;
    }

    /**
     * Get APNs server URL based on environment
     *
     * @return string APNs server URL
     */
    private function getServerUrl() {
        return $this->useSandbox
            ? 'https://api.sandbox.push.apple.com'
            : 'https://api.push.apple.com';
    }

    /**
     * Generate JWT token for authentication
     * JWT tokens are valid for up to 1 hour and can be reused
     *
     * @return string JWT token
     */
    private function generateJWT() {
        // Reuse existing JWT if still valid (expires in 59 minutes)
        if ($this->jwt && time() < $this->jwtExpiry) {
            return $this->jwt;
        }

        // Load the private key
        if (!file_exists($this->authKeyPath)) {
            throw new Exception(
                "Auth key file not found at: {$this->authKeyPath}\n" .
                "Please check:\n" .
                "1. The file exists at this location\n" .
                "2. The path in apns-config.php is correct\n" .
                "3. You have downloaded the .p8 file from Apple Developer Portal"
            );
        }

        if (!is_readable($this->authKeyPath)) {
            throw new Exception("Auth key file is not readable: {$this->authKeyPath}\nCheck file permissions.");
        }

        $privateKey = file_get_contents($this->authKeyPath);
        if (!$privateKey) {
            throw new Exception("Failed to read auth key from: {$this->authKeyPath}");
        }

        // Create JWT header
        $header = [
            'alg' => 'ES256',
            'kid' => $this->keyId
        ];

        // Create JWT claims
        $claims = [
            'iss' => $this->teamId,
            'iat' => time()
        ];

        // Encode header and claims
        $headerEncoded = $this->base64UrlEncode(json_encode($header));
        $claimsEncoded = $this->base64UrlEncode(json_encode($claims));

        // Create signature
        $signature = '';
        $dataToSign = $headerEncoded . '.' . $claimsEncoded;

        $key = openssl_pkey_get_private($privateKey);
        if (!$key) {
            throw new Exception("Failed to parse private key");
        }

        openssl_sign($dataToSign, $signature, $key, OPENSSL_ALGO_SHA256);
        $signatureEncoded = $this->base64UrlEncode($signature);

        // Create JWT
        $this->jwt = $dataToSign . '.' . $signatureEncoded;
        $this->jwtExpiry = time() + 3540; // 59 minutes

        return $this->jwt;
    }

    /**
     * Base64 URL encode
     *
     * @param string $data Data to encode
     * @return string Encoded data
     */
    private function base64UrlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Send notification to a device
     *
     * @param string $deviceToken The APNs device token (fcmToken from registration)
     * @param array $notification Notification payload
     * @param array $options Additional options (priority, expiration, etc.)
     * @return array Response with success status and details
     */
    public function sendNotification($deviceToken, $notification, $options = []) {
        // Generate JWT token
        $jwt = $this->generateJWT();

        // Build the request URL
        $url = $this->getServerUrl() . '/3/device/' . $deviceToken;

        // Prepare the payload
        $payload = json_encode($notification);

        // Prepare headers
        $headers = [
            'authorization: bearer ' . $jwt,
            'apns-topic: ' . $this->bundleId,
            'content-type: application/json'
        ];

        // Add optional headers
        if (isset($options['priority'])) {
            $headers[] = 'apns-priority: ' . $options['priority'];
        }

        if (isset($options['expiration'])) {
            $headers[] = 'apns-expiration: ' . $options['expiration'];
        }

        if (isset($options['collapseId'])) {
            $headers[] = 'apns-collapse-id: ' . $options['collapseId'];
        }

        if (isset($options['pushType'])) {
            $headers[] = 'apns-push-type: ' . $options['pushType'];
        } else {
            $headers[] = 'apns-push-type: alert';
        }

        // Initialize cURL with HTTP/2
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
            CURLOPT_HEADER => true
        ]);

        // Execute request
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);

        if (curl_errno($ch)) {
            $error = curl_error($ch);
            curl_close($ch);
            throw new Exception("cURL error: $error");
        }

        curl_close($ch);

        // Parse response
        $responseHeaders = substr($response, 0, $headerSize);
        $responseBody = substr($response, $headerSize);

        // Extract apns-id from headers
        $apnsId = null;
        if (preg_match('/apns-id:\s*([a-zA-Z0-9-]+)/i', $responseHeaders, $matches)) {
            $apnsId = $matches[1];
        }

        $result = [
            'success' => ($httpCode == 200),
            'httpCode' => $httpCode,
            'apnsId' => $apnsId,
            'deviceToken' => $deviceToken
        ];

        if ($httpCode != 200) {
            $result['error'] = json_decode($responseBody, true);
        }

        return $result;
    }

    /**
     * Send notification to multiple devices
     *
     * @param array $deviceTokens Array of device tokens
     * @param array $notification Notification payload
     * @param array $options Additional options
     * @return array Array of results for each device
     */
    public function sendBulkNotifications($deviceTokens, $notification, $options = []) {
        $results = [];

        foreach ($deviceTokens as $token) {
            try {
                $results[] = $this->sendNotification($token, $notification, $options);
            } catch (Exception $e) {
                $results[] = [
                    'success' => false,
                    'deviceToken' => $token,
                    'error' => $e->getMessage()
                ];
            }
        }

        return $results;
    }

    /**
     * Build a simple alert notification payload
     *
     * @param string $title Notification title
     * @param string $body Notification body
     * @param array $customData Custom data to include
     * @return array Notification payload
     */
    public static function buildAlertNotification($title, $body, $customData = []) {
        $payload = [
            'aps' => [
                'alert' => [
                    'title' => $title,
                    'body' => $body
                ],
                'sound' => 'default',
                'badge' => 1
            ]
        ];

        // Add custom data
        if (!empty($customData)) {
            foreach ($customData as $key => $value) {
                $payload[$key] = $value;
            }
        }

        return $payload;
    }

    /**
     * Build a silent notification payload (for background updates)
     *
     * @param array $customData Custom data to include
     * @return array Notification payload
     */
    public static function buildSilentNotification($customData = []) {
        $payload = [
            'aps' => [
                'content-available' => 1
            ]
        ];

        // Add custom data
        if (!empty($customData)) {
            foreach ($customData as $key => $value) {
                $payload[$key] = $value;
            }
        }

        return $payload;
    }
}
