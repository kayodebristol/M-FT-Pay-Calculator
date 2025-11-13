#!/bin/bash
# macOS Code Signing and Notarization Script
# Signs macOS app bundles and DMG files, then submits for notarization

set -e

MSI_PATH="${1:-}"
CERTIFICATE_NAME="${APPLE_SIGNING_IDENTITY:-}"
TEAM_ID="${APPLE_TEAM_ID:-}"
APPLE_ID="${APPLE_ID:-}"
APPLE_PASSWORD="${APPLE_PASSWORD:-}"
APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-}"

if [ -z "$MSI_PATH" ]; then
    echo "Usage: $0 <app-bundle-path>"
    echo "Environment variables:"
    echo "  APPLE_SIGNING_IDENTITY - Code signing identity (e.g., 'Developer ID Application: Your Name')"
    echo "  APPLE_TEAM_ID - Your Apple Team ID"
    echo "  APPLE_ID - Your Apple ID email"
    echo "  APPLE_PASSWORD - Apple ID password (or use APPLE_APP_SPECIFIC_PASSWORD)"
    echo "  APPLE_APP_SPECIFIC_PASSWORD - App-specific password (recommended)"
    exit 1
fi

if [ ! -d "$MSI_PATH" ] && [ ! -f "$MSI_PATH" ]; then
    echo "Error: Path not found: $MSI_PATH"
    exit 1
fi

# Determine if it's an app bundle or DMG
if [[ "$MSI_PATH" == *.dmg ]]; then
    IS_DMG=true
    echo "Signing DMG: $MSI_PATH"
else
    IS_DMG=false
    echo "Signing App Bundle: $MSI_PATH"
fi

# Sign the app bundle or DMG
if [ "$IS_DMG" = true ]; then
    # Sign DMG
    if [ -z "$CERTIFICATE_NAME" ]; then
        echo "Error: APPLE_SIGNING_IDENTITY not set"
        exit 1
    fi
    
    codesign --force --verify --verbose --sign "$CERTIFICATE_NAME" "$MSI_PATH"
    echo "✓ Signed DMG: $MSI_PATH"
else
    # Sign app bundle
    if [ -z "$CERTIFICATE_NAME" ]; then
        echo "Error: APPLE_SIGNING_IDENTITY not set"
        exit 1
    fi
    
    # Sign all nested executables and libraries
    find "$MSI_PATH" -type f -perm +111 -exec codesign --force --verify --verbose --sign "$CERTIFICATE_NAME" {} \;
    
    # Sign the app bundle itself
    codesign --force --verify --verbose --sign "$CERTIFICATE_NAME" --options runtime "$MSI_PATH"
    echo "✓ Signed App Bundle: $MSI_PATH"
fi

# Verify signature
codesign --verify --deep --strict --verbose=2 "$MSI_PATH"
if [ $? -eq 0 ]; then
    echo "✓ Signature verified"
else
    echo "✗ Signature verification failed"
    exit 1
fi

# Notarization (only for distribution outside App Store)
if [ "$IS_DMG" = true ] || [ -n "$APPLE_ID" ]; then
    if [ -z "$APPLE_ID" ] || [ -z "$TEAM_ID" ]; then
        echo "Warning: Notarization skipped (APPLE_ID or APPLE_TEAM_ID not set)"
        exit 0
    fi
    
    echo "Submitting for notarization..."
    
    # Create a zip for notarization (DMG can be submitted directly)
    if [ "$IS_DMG" = false ]; then
        ZIP_PATH="${MSI_PATH%.app}.zip"
        ditto -c -k --keepParent "$MSI_PATH" "$ZIP_PATH"
        NOTARIZE_PATH="$ZIP_PATH"
    else
        NOTARIZE_PATH="$MSI_PATH"
    fi
    
    # Submit for notarization
    PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-$APPLE_PASSWORD}"
    xcrun notarytool submit "$NOTARIZE_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$TEAM_ID" \
        --password "$PASSWORD" \
        --wait
    
    if [ $? -eq 0 ]; then
        echo "✓ Notarization successful"
        
        # Staple the notarization ticket
        if [ "$IS_DMG" = false ] && [ -f "$ZIP_PATH" ]; then
            xcrun stapler staple "$MSI_PATH"
            rm "$ZIP_PATH"
        else
            xcrun stapler staple "$MSI_PATH"
        fi
        
        echo "✓ Notarization ticket stapled"
    else
        echo "✗ Notarization failed"
        exit 1
    fi
fi

