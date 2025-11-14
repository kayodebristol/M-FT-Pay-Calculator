#!/bin/bash
# iOS Code Signing Helper Script
# Note: iOS signing is primarily handled by Xcode and App Store Connect API
# This script provides helper functions for manual signing if needed

set -e

IPA_PATH="${1:-}"
PROVISIONING_PROFILE="${APPLE_PROVISIONING_PROFILE:-}"
CERTIFICATE_NAME="${APPLE_SIGNING_IDENTITY:-}"
TEAM_ID="${APPLE_TEAM_ID:-}"

if [ -z "$IPA_PATH" ]; then
    echo "Usage: $0 <ipa-path>"
    echo ""
    echo "Note: iOS apps are typically signed automatically during build."
    echo "This script is for manual signing scenarios only."
    echo ""
    echo "Environment variables:"
    echo "  APPLE_PROVISIONING_PROFILE - Path to .mobileprovision file"
    echo "  APPLE_SIGNING_IDENTITY - Code signing identity"
    echo "  APPLE_TEAM_ID - Your Apple Team ID"
    exit 1
fi

if [ ! -f "$IPA_PATH" ]; then
    echo "Error: IPA file not found: $IPA_PATH"
    exit 1
fi

echo "iOS Code Signing Helper"
echo "======================"
echo ""
echo "For iOS apps, signing is typically handled by:"
echo "1. Xcode during build (automatic)"
echo "2. App Store Connect API (via GitHub Actions)"
echo "3. Fastlane (automated workflows)"
echo ""
echo "Manual signing is rarely needed, but if required:"
echo ""
echo "1. Extract IPA:"
echo "   unzip -q \"$IPA_PATH\" -d temp_ipa"
echo ""
echo "2. Replace embedded.mobileprovision:"
if [ -n "$PROVISIONING_PROFILE" ]; then
    echo "   cp \"$PROVISIONING_PROFILE\" temp_ipa/Payload/*.app/embedded.mobileprovision"
else
    echo "   # Set APPLE_PROVISIONING_PROFILE environment variable"
fi
echo ""
echo "3. Sign the app:"
if [ -n "$CERTIFICATE_NAME" ] && [ -n "$TEAM_ID" ]; then
    echo "   codesign --force --sign \"$CERTIFICATE_NAME\" --entitlements entitlements.plist temp_ipa/Payload/*.app"
else
    echo "   # Set APPLE_SIGNING_IDENTITY and APPLE_TEAM_ID environment variables"
fi
echo ""
echo "4. Repackage IPA:"
echo "   cd temp_ipa && zip -qr ../signed.ipa . && cd .."
echo ""
echo "For automated signing, use:"
echo "- GitHub Actions with App Store Connect API (see TESTFLIGHT_SETUP.md)"
echo "- Fastlane (recommended for complex workflows)"
echo ""
echo "See TESTFLIGHT_SETUP.md for App Store Connect API setup."

