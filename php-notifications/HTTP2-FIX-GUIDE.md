# HTTP/2 Support Fix Guide

Your cURL version 7.53.1 doesn't support HTTP/2, which is required for APNs. Here's how to fix it:

## Quick Diagnosis

Run this script to see exactly what's wrong:
```bash
chmod +x diagnose-http2.sh
./diagnose-http2.sh
```

## Step-by-Step Fix

### Step 1: Check which curl you're using

```bash
which curl
# Likely shows: /usr/bin/curl (system curl - OLD)

which -a curl
# Should show multiple locations if Homebrew curl is installed
```

### Step 2: Install/Upgrade curl via Homebrew

```bash
# Install curl with HTTP/2 support
brew install curl

# Or if already installed:
brew upgrade curl

# Verify Homebrew curl has HTTP/2
/opt/homebrew/opt/curl/bin/curl --version | grep HTTP2
# OR on Intel Mac:
/usr/local/opt/curl/bin/curl --version | grep HTTP2

# Should show: Features: ... HTTP2 ...
```

### Step 3: Make Homebrew curl the default

Your PATH needs to prioritize Homebrew's curl over the system curl.

**For zsh (default on modern macOS):**
```bash
echo 'export PATH="/opt/homebrew/opt/curl/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo 'export PATH="/opt/homebrew/opt/curl/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

**For Intel Macs (not Apple Silicon):**
Use `/usr/local/opt/curl/bin` instead of `/opt/homebrew/opt/curl/bin`

### Step 4: Verify curl now has HTTP/2

```bash
which curl
# Should now show: /opt/homebrew/opt/curl/bin/curl (or /usr/local/opt/curl/bin/curl)

curl --version | grep HTTP2
# Should show: Features: ... HTTP2 ...
```

### Step 5: Reinstall PHP to use new curl

```bash
# Reinstall PHP so it picks up the new curl
brew reinstall php

# Or upgrade if you have an old version
brew upgrade php
```

### Step 6: Verify PHP has HTTP/2

```bash
php -r "echo curl_version()['version'] . PHP_EOL;"
# Should show a newer version

php -r "if (curl_version()['features'] & CURL_VERSION_HTTP2) { echo 'HTTP/2 supported'; } else { echo 'HTTP/2 NOT supported'; }"
# Should show: HTTP/2 supported
```

### Step 7: Test the connection

```bash
cd /Users/jcohen/git/phprepository/CloudCrypto/php-notifications
php test-connection.php
```

You should now see:
```
✓ HTTP/2 is supported
✓ Success: HTTP 200 (or 400/403 for APNs)
✓ HTTP/2 is working!
```

## Still Not Working?

### Option A: Use a different PHP installation

If Homebrew PHP doesn't work, try MAMP:

1. Download [MAMP](https://www.mamp.info/en/downloads/)
2. Install it
3. Use MAMP's PHP: `/Applications/MAMP/bin/php/php8.x.x/bin/php`
4. Run: `/Applications/MAMP/bin/php/php8.2.0/bin/php test-connection.php`

### Option B: Check Homebrew prefix

On Apple Silicon Macs, Homebrew uses `/opt/homebrew`
On Intel Macs, Homebrew uses `/usr/local`

Verify with:
```bash
brew --prefix
```

Then use the correct path in your PATH export.

### Option C: Fresh PHP installation

```bash
# Remove PHP completely
brew uninstall php

# Install curl first
brew install curl

# Add to PATH (use correct prefix from "brew --prefix")
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Install PHP fresh
brew install php

# Test
php test-connection.php
```

## What Success Looks Like

When everything is working, `test-connection.php` will show:

```
========================================
APNs Connection Test
========================================

1. Checking HTTP/2 support...
   cURL version: 8.4.0
   ✓ HTTP/2 is supported
   ✓ CURL_HTTP_VERSION_2_0 constant is defined

2. Testing basic HTTPS connectivity...
   Testing: Apple main site (https://www.apple.com)
      ✓ Success: HTTP 200
   Testing: APNs Sandbox (https://api.sandbox.push.apple.com)
      ✓ Success: HTTP 403
   Testing: APNs Production (https://api.push.apple.com)
      ✓ Success: HTTP 403

3. Testing HTTP/2 connection to APNs...
   ✓ Connection successful
   HTTP Code: 403
   Protocol: HTTP/2.0
   ✓ HTTP/2 is working!

4. Testing mock APNs notification request...
   ✓ Request completed
   HTTP Code: 403
   ✓ Got 403 (authentication failed) - this is expected!
```

The 403 errors are GOOD - they mean the connection works, it's just rejecting the fake auth token (which is expected).

## Then Send Real Notifications

Once HTTP/2 is working:

```bash
php send-notification.php
```

You should see successful notifications being sent!

## Troubleshooting Commands

```bash
# Check all curl locations
which -a curl

# Check what curl PHP is using
php -r "phpinfo();" | grep -i curl

# Check Homebrew's curl specifically
$(brew --prefix)/opt/curl/bin/curl --version

# Check your PATH
echo $PATH

# Check your shell
echo $SHELL
```

## Need More Help?

If you're still stuck:
1. Run `./diagnose-http2.sh` and share the output
2. Run `php -i | grep -i curl` and share the output
3. Check if you're using the right shell config file (.zshrc vs .bash_profile)
