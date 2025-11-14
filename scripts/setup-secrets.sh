#!/bin/bash

# Setup GitHub Secrets for Microsoft Pay Calculator
# This script helps you set up all required secrets using GitHub CLI

set -e

echo "🔐 GitHub Secrets Setup for Microsoft Pay Calculator"
echo "=================================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "   Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "⚠️  Not authenticated with GitHub CLI"
    echo "   Running: gh auth login"
    gh auth login
fi

echo "✅ Authenticated with GitHub CLI"
echo ""

# Function to set secret from file
set_secret_from_file() {
    local secret_name=$1
    local file_path=$2
    local description=$3
    
    if [ -f "$file_path" ]; then
        echo "Setting $secret_name from $file_path..."
        cat "$file_path" | base64 -w 0 | gh secret set "$secret_name"
        echo "✅ $secret_name set successfully"
    else
        echo "⚠️  File not found: $file_path"
        echo "   Skipping $secret_name"
    fi
    echo ""
}

# Function to set secret from input
set_secret_from_input() {
    local secret_name=$1
    local description=$2
    
    echo "Setting $secret_name..."
    echo "$description"
    read -sp "Enter value (hidden): " value
    echo ""
    if [ -n "$value" ]; then
        echo "$value" | gh secret set "$secret_name"
        echo "✅ $secret_name set successfully"
    else
        echo "⚠️  Empty value, skipping $secret_name"
    fi
    echo ""
}

# Tauri Update Signing
echo "📦 Tauri Update Signing"
echo "----------------------"
read -p "Do you want to set up Tauri signing key? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Path to Tauri signing key (~/.tauri/myapp.key): " key_path
    key_path=${key_path:-~/.tauri/myapp.key}
    key_path="${key_path/#\~/$HOME}"
    set_secret_from_file "TAURI_SIGNING_KEY" "$key_path" "Tauri signing private key"
fi

# Windows Code Signing
echo "🪟 Windows Code Signing"
echo "----------------------"
read -p "Do you want to set up Windows code signing? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Path to Windows certificate (.pfx): " cert_path
    if [ -f "$cert_path" ]; then
        echo "Encoding and setting WINDOWS_SIGNING_CERTIFICATE..."
        cat "$cert_path" | base64 -w 0 | gh secret set WINDOWS_SIGNING_CERTIFICATE
        echo "✅ WINDOWS_SIGNING_CERTIFICATE set"
        echo ""
        set_secret_from_input "WINDOWS_SIGNING_CERTIFICATE_PASSWORD" "Certificate password"
    else
        echo "⚠️  Certificate file not found: $cert_path"
    fi
fi

# macOS Code Signing
echo "🍎 macOS Code Signing"
echo "----------------------"
read -p "Do you want to set up macOS code signing? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Path to macOS certificate: " cert_path
    if [ -f "$cert_path" ]; then
        echo "Encoding and setting MACOS_SIGNING_CERTIFICATE..."
        cat "$cert_path" | base64 -w 0 | gh secret set MACOS_SIGNING_CERTIFICATE
        echo "✅ MACOS_SIGNING_CERTIFICATE set"
        echo ""
        set_secret_from_input "MACOS_SIGNING_CERTIFICATE_PASSWORD" "Certificate password"
    else
        echo "⚠️  Certificate file not found: $cert_path"
    fi
fi

# iOS App Store Connect API
echo "📱 iOS App Store Connect API"
echo "----------------------------"
read -p "Do you want to set up App Store Connect API credentials? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "API Key ID: " api_key_id
    read -p "Issuer ID: " issuer_id
    read -p "Path to .p8 private key file: " p8_path
    
    if [ -n "$api_key_id" ] && [ -n "$issuer_id" ] && [ -f "$p8_path" ]; then
        echo "$api_key_id" | gh secret set APPSTORE_API_KEY_ID
        echo "✅ APPSTORE_API_KEY_ID set"
        echo "$issuer_id" | gh secret set APPSTORE_ISSUER_ID
        echo "✅ APPSTORE_ISSUER_ID set"
        cat "$p8_path" | gh secret set APPSTORE_API_PRIVATE_KEY
        echo "✅ APPSTORE_API_PRIVATE_KEY set"
    else
        echo "⚠️  Missing required information or file not found"
    fi
fi

# List all secrets
echo ""
echo "📋 Current Secrets"
echo "-----------------"
gh secret list

echo ""
echo "✅ Setup complete!"
echo ""
echo "💡 Tip: You can manage secrets anytime using:"
echo "   - gh secret list          # List all secrets"
echo "   - gh secret set NAME       # Set a secret"
echo "   - gh secret delete NAME   # Delete a secret"

