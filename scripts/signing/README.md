# Code Signing Scripts

This directory contains platform-specific code signing scripts for the Microsoft Pay Calculator application.

## Scripts

### Windows (`windows-sign.ps1`)

Signs Windows MSI installers using a code signing certificate.

**Prerequisites:**
- Windows SDK (includes signtool.exe)
- Code signing certificate (.pfx file)

**Usage:**
```powershell
# Using environment variables
$env:WINDOWS_SIGNING_CERTIFICATE_PATH = "path/to/certificate.pfx"
$env:WINDOWS_SIGNING_CERTIFICATE_PASSWORD = "certificate-password"
.\scripts\signing\windows-sign.ps1 -MsiPath "path/to/installer.msi"

# Or specify parameters directly
.\scripts\signing\windows-sign.ps1 -MsiPath "installer.msi" -CertificatePath "cert.pfx" -CertificatePassword "password"
```

**Environment Variables:**
- `WINDOWS_SIGNING_CERTIFICATE_PATH` - Path to .pfx certificate file
- `WINDOWS_SIGNING_CERTIFICATE_PASSWORD` - Certificate password

### macOS (`macos-sign.sh`)

Signs macOS app bundles and DMG files, then submits for notarization.

**Prerequisites:**
- Xcode Command Line Tools
- Apple Developer account
- Code signing certificate installed in Keychain

**Usage:**
```bash
# Sign app bundle
export APPLE_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
export APPLE_TEAM_ID="YOUR_TEAM_ID"
export APPLE_ID="your@email.com"
export APPLE_APP_SPECIFIC_PASSWORD="app-specific-password"

./scripts/signing/macos-sign.sh "path/to/App.app"

# Sign DMG
./scripts/signing/macos-sign.sh "path/to/installer.dmg"
```

**Environment Variables:**
- `APPLE_SIGNING_IDENTITY` - Code signing identity (e.g., "Developer ID Application: Name")
- `APPLE_TEAM_ID` - Your Apple Team ID
- `APPLE_ID` - Your Apple ID email
- `APPLE_PASSWORD` - Apple ID password (or use APPLE_APP_SPECIFIC_PASSWORD)
- `APPLE_APP_SPECIFIC_PASSWORD` - App-specific password (recommended)

### Android (`android-keystore.sh`)

Creates and manages Android signing keystores.

**Prerequisites:**
- Java JDK (for keytool)
- Android SDK (optional, for build tools)

**Usage:**
```bash
# Create new keystore
export ANDROID_KEYSTORE_PATH="android-release-key.jks"
export ANDROID_KEYSTORE_PASSWORD="your-password"
export ANDROID_KEY_ALIAS="release"
export ANDROID_KEY_PASSWORD="your-password"

./scripts/signing/android-keystore.sh create

# Verify keystore
./scripts/signing/android-keystore.sh verify

# Show keystore info
./scripts/signing/android-keystore.sh info
```

**Environment Variables:**
- `ANDROID_KEYSTORE_PATH` - Path to keystore file
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias (default: release)
- `ANDROID_KEY_PASSWORD` - Key password
- `ANDROID_KEY_VALIDITY` - Validity in days (default: 10000)

### Linux (`linux-sign.sh`)

Signs Linux DEB and RPM packages using GPG.

**Prerequisites:**
- GPG installed
- GPG key pair generated

**Usage:**
```bash
# Generate GPG key (if needed)
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format LONG

# Sign DEB package
export GPG_KEY_ID="YOUR_KEY_ID"
export GPG_PASSPHRASE="your-passphrase"
./scripts/signing/linux-sign.sh "package.deb"

# Sign RPM package
./scripts/signing/linux-sign.sh "package.rpm"
```

**Environment Variables:**
- `GPG_KEY_ID` - GPG key ID for signing
- `GPG_PASSPHRASE` - GPG key passphrase

## Security Best Practices

1. **Never commit certificates or keystores to git**
   - Add to `.gitignore`
   - Store in secure password manager or secret management system

2. **Use environment variables for sensitive data**
   - Never hardcode passwords or keys in scripts
   - Use GitHub Secrets for CI/CD

3. **Rotate keys regularly**
   - Update certificates before expiration
   - Keep backup of old keys for app updates

4. **Use app-specific passwords**
   - For Apple services, use app-specific passwords instead of main password
   - Revoke app-specific passwords if compromised

5. **Store backups securely**
   - Keep encrypted backups of certificates and keystores
   - Store in multiple secure locations

## Integration with CI/CD

These scripts are designed to work with GitHub Actions. See `.github/workflows/` for integration examples.

For GitHub Secrets, add:
- Windows: `WINDOWS_SIGNING_CERTIFICATE` (base64 encoded), `WINDOWS_SIGNING_CERTIFICATE_PASSWORD`
- macOS: `APPLE_SIGNING_IDENTITY`, `APPLE_TEAM_ID`, `APPLE_APP_SPECIFIC_PASSWORD`
- Android: `ANDROID_KEYSTORE` (base64 encoded), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`
- Linux: `GPG_KEY_ID`, `GPG_PRIVATE_KEY` (base64 encoded), `GPG_PASSPHRASE`

## Troubleshooting

### Windows
- **signtool not found**: Install Windows SDK
- **Certificate error**: Ensure certificate is valid and not expired
- **Timestamp server error**: Try alternative timestamp servers

### macOS
- **Codesign error**: Check certificate is installed in Keychain
- **Notarization timeout**: Increase wait time or check Apple Developer status
- **Stapling fails**: Ensure notarization completed successfully

### Android
- **Keytool not found**: Install Java JDK
- **Keystore error**: Verify keystore path and password
- **Build fails**: Ensure keystore is configured in `src-tauri/android/app/build.gradle`

### Linux
- **GPG key not found**: Generate key with `gpg --full-generate-key`
- **Signing fails**: Check GPG key ID and passphrase
- **Verification fails**: Ensure public key is distributed

