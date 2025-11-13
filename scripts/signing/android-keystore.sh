#!/bin/bash
# Android Keystore Management Script
# Creates and manages Android signing keystores

set -e

KEYSTORE_PATH="${ANDROID_KEYSTORE_PATH:-android-release-key.jks}"
KEYSTORE_PASSWORD="${ANDROID_KEYSTORE_PASSWORD:-}"
KEY_ALIAS="${ANDROID_KEY_ALIAS:-release}"
KEY_PASSWORD="${ANDROID_KEY_PASSWORD:-}"
KEY_VALIDITY="${ANDROID_KEY_VALIDITY:-10000}"

create_keystore() {
    if [ -f "$KEYSTORE_PATH" ]; then
        echo "Warning: Keystore already exists: $KEYSTORE_PATH"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted"
            exit 0
        fi
    fi
    
    if [ -z "$KEYSTORE_PASSWORD" ]; then
        read -sp "Enter keystore password: " KEYSTORE_PASSWORD
        echo
        read -sp "Confirm keystore password: " KEYSTORE_PASSWORD_CONFIRM
        echo
        
        if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
            echo "Error: Passwords do not match"
            exit 1
        fi
    fi
    
    if [ -z "$KEY_PASSWORD" ]; then
        KEY_PASSWORD="$KEYSTORE_PASSWORD"
    fi
    
    echo "Creating keystore: $KEYSTORE_PATH"
    echo "Key alias: $KEY_ALIAS"
    echo "Validity: $KEY_VALIDITY days"
    
    keytool -genkey -v \
        -keystore "$KEYSTORE_PATH" \
        -alias "$KEY_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity "$KEY_VALIDITY" \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEY_PASSWORD" \
        -dname "CN=Microsoft Pay Calculator, OU=Development, O=Microsoft, L=Redmond, ST=Washington, C=US"
    
    echo "✓ Keystore created successfully"
    echo ""
    echo "IMPORTANT: Store these credentials securely:"
    echo "  Keystore: $KEYSTORE_PATH"
    echo "  Keystore Password: [stored securely]"
    echo "  Key Alias: $KEY_ALIAS"
    echo "  Key Password: [stored securely]"
}

verify_keystore() {
    if [ ! -f "$KEYSTORE_PATH" ]; then
        echo "Error: Keystore not found: $KEYSTORE_PATH"
        exit 1
    fi
    
    if [ -z "$KEYSTORE_PASSWORD" ]; then
        read -sp "Enter keystore password: " KEYSTORE_PASSWORD
        echo
    fi
    
    echo "Verifying keystore: $KEYSTORE_PATH"
    keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"
    
    if [ $? -eq 0 ]; then
        echo "✓ Keystore is valid"
    else
        echo "✗ Keystore verification failed"
        exit 1
    fi
}

show_info() {
    if [ ! -f "$KEYSTORE_PATH" ]; then
        echo "Error: Keystore not found: $KEYSTORE_PATH"
        exit 1
    fi
    
    if [ -z "$KEYSTORE_PASSWORD" ]; then
        read -sp "Enter keystore password: " KEYSTORE_PASSWORD
        echo
    fi
    
    echo "Keystore Information:"
    echo "==================="
    keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" | grep -E "(Alias name|Valid from|Certificate fingerprints)"
}

case "${1:-create}" in
    create)
        create_keystore
        ;;
    verify)
        verify_keystore
        ;;
    info)
        show_info
        ;;
    *)
        echo "Usage: $0 [create|verify|info]"
        echo ""
        echo "Environment variables:"
        echo "  ANDROID_KEYSTORE_PATH - Path to keystore file (default: android-release-key.jks)"
        echo "  ANDROID_KEYSTORE_PASSWORD - Keystore password"
        echo "  ANDROID_KEY_ALIAS - Key alias (default: release)"
        echo "  ANDROID_KEY_PASSWORD - Key password"
        echo "  ANDROID_KEY_VALIDITY - Validity in days (default: 10000)"
        exit 1
        ;;
esac

