#!/bin/bash

echo "========================================"
echo "HTTP/2 Setup Diagnostic & Fix Script"
echo "========================================"
echo ""

# Check current curl
echo "1. Checking current curl installation..."
echo "   Command curl location:"
which curl
echo ""
echo "   All curl locations:"
which -a curl
echo ""
echo "   Current curl version:"
curl --version | head -n 1
echo ""
echo "   HTTP/2 support:"
if curl --version | grep -q HTTP2; then
    echo "   ✓ HTTP/2 IS supported"
else
    echo "   ✗ HTTP/2 NOT supported"
fi
echo ""

# Check if Homebrew is installed
echo "2. Checking Homebrew..."
if command -v brew &> /dev/null; then
    echo "   ✓ Homebrew is installed"
    echo "   Homebrew prefix: $(brew --prefix)"

    # Check if curl is installed via Homebrew
    if brew list curl &> /dev/null; then
        echo "   ✓ curl is installed via Homebrew"
        echo "   Homebrew curl location: $(brew --prefix)/opt/curl/bin/curl"

        # Check Homebrew curl version
        BREW_CURL=$(brew --prefix)/opt/curl/bin/curl
        if [ -f "$BREW_CURL" ]; then
            echo ""
            echo "   Homebrew curl version:"
            $BREW_CURL --version | head -n 1
            echo ""
            echo "   Homebrew curl HTTP/2 support:"
            if $BREW_CURL --version | grep -q HTTP2; then
                echo "   ✓ HTTP/2 IS supported in Homebrew curl"
            else
                echo "   ✗ HTTP/2 NOT supported in Homebrew curl"
            fi
        fi
    else
        echo "   ✗ curl is NOT installed via Homebrew"
        echo ""
        echo "   Installing curl via Homebrew..."
        brew install curl
    fi
else
    echo "   ✗ Homebrew is NOT installed"
    echo ""
    echo "   To install Homebrew, run:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi
echo ""

# Check PHP
echo "3. Checking PHP..."
echo "   PHP location: $(which php)"
echo "   PHP version: $(php -v | head -n 1)"
echo ""
echo "   PHP's curl version:"
php -r "echo curl_version()['version'] . \"\n\";"
echo ""
echo "   PHP's curl HTTP/2 support:"
php -r "if (curl_version()['features'] & CURL_VERSION_HTTP2) { echo \"✓ HTTP/2 supported\n\"; } else { echo \"✗ HTTP/2 NOT supported\n\"; }"
echo ""

# Suggest fix
echo "========================================"
echo "Recommended Fix"
echo "========================================"
echo ""

BREW_PREFIX=$(brew --prefix)

if ! curl --version | grep -q HTTP2; then
    echo "Your system curl doesn't support HTTP/2."
    echo ""
    echo "To fix this, add Homebrew's curl to your PATH:"
    echo ""

    if [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bash_profile"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.profile"
    fi

    echo "Run these commands:"
    echo ""
    echo "  echo 'export PATH=\"$BREW_PREFIX/opt/curl/bin:\$PATH\"' >> $SHELL_RC"
    echo "  source $SHELL_RC"
    echo ""
    echo "Then verify:"
    echo "  curl --version | grep HTTP2"
    echo ""
fi

PHP_HTTP2=$(php -r "if (curl_version()['features'] & CURL_VERSION_HTTP2) { echo '1'; } else { echo '0'; }" 2>/dev/null || echo "0")

if [ "$PHP_HTTP2" = "0" ]; then
    echo "Your PHP doesn't support HTTP/2."
    echo ""
    echo "To fix this, reinstall PHP after updating curl:"
    echo ""
    echo "  brew reinstall php"
    echo ""
    echo "Or upgrade PHP:"
    echo "  brew upgrade php"
    echo ""
    echo "Then verify:"
    echo "  php test-connection.php"
    echo ""
fi

echo "========================================"
echo "Quick Test"
echo "========================================"
echo ""
echo "After applying the fix, test the connection:"
echo "  php test-connection.php"
echo ""
