# Setup GitHub Secrets for Microsoft Pay Calculator
# PowerShell script for Windows

param(
    [switch]$SkipPrompts
)

$ErrorActionPreference = "Stop"

Write-Host "🔐 GitHub Secrets Setup for Microsoft Pay Calculator" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if gh CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "   Install it from: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host "   Or run: winget install GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Check if authenticated
try {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Not authenticated with GitHub CLI" -ForegroundColor Yellow
        Write-Host "   Running: gh auth login" -ForegroundColor Yellow
        gh auth login
    }
} catch {
    Write-Host "⚠️  Not authenticated with GitHub CLI" -ForegroundColor Yellow
    Write-Host "   Running: gh auth login" -ForegroundColor Yellow
    gh auth login
}

Write-Host "✅ Authenticated with GitHub CLI" -ForegroundColor Green
Write-Host ""

# Function to set secret from file
function Set-SecretFromFile {
    param(
        [string]$SecretName,
        [string]$FilePath,
        [string]$Description
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Setting $SecretName from $FilePath..." -ForegroundColor Cyan
        $content = [System.IO.File]::ReadAllBytes($FilePath)
        $base64 = [Convert]::ToBase64String($content)
        $base64 | gh secret set $SecretName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $SecretName set successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to set $SecretName" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  File not found: $FilePath" -ForegroundColor Yellow
        Write-Host "   Skipping $SecretName" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Function to set secret from input
function Set-SecretFromInput {
    param(
        [string]$SecretName,
        [string]$Description
    )
    
    Write-Host "Setting $SecretName..." -ForegroundColor Cyan
    Write-Host $Description -ForegroundColor Gray
    $secureValue = Read-Host "Enter value (hidden)" -AsSecureString
    $value = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureValue)
    )
    
    if ($value) {
        $value | gh secret set $SecretName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $SecretName set successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to set $SecretName" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Empty value, skipping $SecretName" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Function to set secret from plain text input
function Set-SecretFromPlainInput {
    param(
        [string]$SecretName,
        [string]$Description,
        [string]$DefaultValue = ""
    )
    
    Write-Host "Setting $SecretName..." -ForegroundColor Cyan
    Write-Host $Description -ForegroundColor Gray
    if ($DefaultValue) {
        $value = Read-Host "Enter value" -Default $DefaultValue
    } else {
        $value = Read-Host "Enter value"
    }
    
    if ($value) {
        $value | gh secret set $SecretName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $SecretName set successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to set $SecretName" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Empty value, skipping $SecretName" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Tauri Update Signing
Write-Host "📦 Tauri Update Signing" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Gray
if (-not $SkipPrompts) {
    $response = Read-Host "Do you want to set up Tauri signing key? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $defaultPath = "$env:USERPROFILE\.tauri\myapp.key"
        $keyPath = Read-Host "Path to Tauri signing key" -Default $defaultPath
        Set-SecretFromFile "TAURI_SIGNING_KEY" $keyPath "Tauri signing private key"
    }
}

# Windows Code Signing
Write-Host "🪟 Windows Code Signing" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Gray
if (-not $SkipPrompts) {
    $response = Read-Host "Do you want to set up Windows code signing? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $certPath = Read-Host "Path to Windows certificate (.pfx)"
        if (Test-Path $certPath) {
            Write-Host "Encoding and setting WINDOWS_SIGNING_CERTIFICATE..." -ForegroundColor Cyan
            $certBytes = [System.IO.File]::ReadAllBytes($certPath)
            $certBase64 = [Convert]::ToBase64String($certBytes)
            $certBase64 | gh secret set WINDOWS_SIGNING_CERTIFICATE
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ WINDOWS_SIGNING_CERTIFICATE set" -ForegroundColor Green
            }
            Write-Host ""
            Set-SecretFromInput "WINDOWS_SIGNING_CERTIFICATE_PASSWORD" "Certificate password"
        } else {
            Write-Host "⚠️  Certificate file not found: $certPath" -ForegroundColor Yellow
        }
    }
}

# macOS Code Signing
Write-Host "🍎 macOS Code Signing" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Gray
if (-not $SkipPrompts) {
    $response = Read-Host "Do you want to set up macOS code signing? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $certPath = Read-Host "Path to macOS certificate"
        if (Test-Path $certPath) {
            Write-Host "Encoding and setting MACOS_SIGNING_CERTIFICATE..." -ForegroundColor Cyan
            $certBytes = [System.IO.File]::ReadAllBytes($certPath)
            $certBase64 = [Convert]::ToBase64String($certBytes)
            $certBase64 | gh secret set MACOS_SIGNING_CERTIFICATE
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ MACOS_SIGNING_CERTIFICATE set" -ForegroundColor Green
            }
            Write-Host ""
            Set-SecretFromInput "MACOS_SIGNING_CERTIFICATE_PASSWORD" "Certificate password"
        } else {
            Write-Host "⚠️  Certificate file not found: $certPath" -ForegroundColor Yellow
        }
    }
}

# iOS App Store Connect API
Write-Host "📱 iOS App Store Connect API" -ForegroundColor Cyan
Write-Host "----------------------------" -ForegroundColor Gray
if (-not $SkipPrompts) {
    $response = Read-Host "Do you want to set up App Store Connect API credentials? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $apiKeyId = Read-Host "API Key ID"
        $issuerId = Read-Host "Issuer ID"
        $p8Path = Read-Host "Path to .p8 private key file"
        
        if ($apiKeyId -and $issuerId -and (Test-Path $p8Path)) {
            $apiKeyId | gh secret set APPSTORE_API_KEY_ID
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ APPSTORE_API_KEY_ID set" -ForegroundColor Green
            }
            $issuerId | gh secret set APPSTORE_ISSUER_ID
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ APPSTORE_ISSUER_ID set" -ForegroundColor Green
            }
            Get-Content $p8Path -Raw | gh secret set APPSTORE_API_PRIVATE_KEY
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ APPSTORE_API_PRIVATE_KEY set" -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️  Missing required information or file not found" -ForegroundColor Yellow
        }
    }
}

# List all secrets
Write-Host ""
Write-Host "📋 Current Secrets" -ForegroundColor Cyan
Write-Host "-----------------" -ForegroundColor Gray
gh secret list

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tip: You can manage secrets anytime using:" -ForegroundColor Cyan
Write-Host "   - gh secret list          # List all secrets" -ForegroundColor Gray
Write-Host "   - gh secret set NAME       # Set a secret" -ForegroundColor Gray
Write-Host "   - gh secret delete NAME   # Delete a secret" -ForegroundColor Gray

