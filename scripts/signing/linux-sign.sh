#!/bin/bash
# Linux Package Signing Script
# Signs DEB and RPM packages (optional but recommended)

set -e

PACKAGE_PATH="${1:-}"
GPG_KEY_ID="${GPG_KEY_ID:-}"
GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"

if [ -z "$PACKAGE_PATH" ]; then
    echo "Usage: $0 <package-path>"
    echo "Environment variables:"
    echo "  GPG_KEY_ID - GPG key ID for signing"
    echo "  GPG_PASSPHRASE - GPG key passphrase"
    exit 1
fi

if [ ! -f "$PACKAGE_PATH" ]; then
    echo "Error: Package not found: $PACKAGE_PATH"
    exit 1
fi

if [ -z "$GPG_KEY_ID" ]; then
    echo "Error: GPG_KEY_ID not set"
    echo "List available keys with: gpg --list-secret-keys --keyid-format LONG"
    exit 1
fi

# Determine package type
if [[ "$PACKAGE_PATH" == *.deb ]]; then
    echo "Signing DEB package: $PACKAGE_PATH"
    
    # Sign DEB package
    if [ -n "$GPG_PASSPHRASE" ]; then
        echo "$GPG_PASSPHRASE" | debsigs --sign=origin -k "$GPG_KEY_ID" "$PACKAGE_PATH"
    else
        debsigs --sign=origin -k "$GPG_KEY_ID" "$PACKAGE_PATH"
    fi
    
    echo "✓ DEB package signed"
    
elif [[ "$PACKAGE_PATH" == *.rpm ]]; then
    echo "Signing RPM package: $PACKAGE_PATH"
    
    # Sign RPM package
    if [ -n "$GPG_PASSPHRASE" ]; then
        echo "$GPG_PASSPHRASE" | rpm --addsign --define "_gpg_name $GPG_KEY_ID" "$PACKAGE_PATH"
    else
        rpm --addsign --define "_gpg_name $GPG_KEY_ID" "$PACKAGE_PATH"
    fi
    
    echo "✓ RPM package signed"
    
else
    echo "Error: Unsupported package format. Expected .deb or .rpm"
    exit 1
fi

# Verify signature
if [[ "$PACKAGE_PATH" == *.deb ]]; then
    debsigs --verify "$PACKAGE_PATH"
    if [ $? -eq 0 ]; then
        echo "✓ DEB signature verified"
    else
        echo "✗ DEB signature verification failed"
        exit 1
    fi
elif [[ "$PACKAGE_PATH" == *.rpm ]]; then
    rpm --checksig "$PACKAGE_PATH"
    if [ $? -eq 0 ]; then
        echo "✓ RPM signature verified"
    else
        echo "✗ RPM signature verification failed"
        exit 1
    fi
fi

