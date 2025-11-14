# GitHub Secrets Management Helper
# Quick commands for managing secrets from PowerShell

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("list", "set", "delete", "get")]
    [string]$Action = "list",
    
    [Parameter(Mandatory=$false)]
    [string]$Name = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Value = "",
    
    [Parameter(Mandatory=$false)]
    [string]$FilePath = ""
)

$ErrorActionPreference = "Stop"

# Check if gh CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "   Install it: winget install GitHub.cli" -ForegroundColor Yellow
    exit 1
}

switch ($Action) {
    "list" {
        Write-Host "📋 Listing GitHub Secrets" -ForegroundColor Cyan
        Write-Host ""
        gh secret list
    }
    
    "set" {
        if (-not $Name) {
            Write-Host "❌ Secret name is required" -ForegroundColor Red
            Write-Host "Usage: .\manage-secrets.ps1 -Action set -Name SECRET_NAME [-Value VALUE] [-FilePath PATH]" -ForegroundColor Yellow
            exit 1
        }
        
        if ($FilePath -and (Test-Path $FilePath)) {
            Write-Host "Setting $Name from file: $FilePath" -ForegroundColor Cyan
            $content = [System.IO.File]::ReadAllBytes($FilePath)
            $base64 = [Convert]::ToBase64String($content)
            $base64 | gh secret set $Name
        } elseif ($Value) {
            Write-Host "Setting $Name from value" -ForegroundColor Cyan
            $Value | gh secret set $Name
        } else {
            Write-Host "Setting $Name (interactive)" -ForegroundColor Cyan
            $secureValue = Read-Host "Enter value" -AsSecureString
            $plainValue = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureValue)
            )
            $plainValue | gh secret set $Name
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Name set successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to set $Name" -ForegroundColor Red
        }
    }
    
    "delete" {
        if (-not $Name) {
            Write-Host "❌ Secret name is required" -ForegroundColor Red
            Write-Host "Usage: .\manage-secrets.ps1 -Action delete -Name SECRET_NAME" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "⚠️  Deleting secret: $Name" -ForegroundColor Yellow
        $confirm = Read-Host "Are you sure? (y/n)"
        if ($confirm -eq 'y' -or $confirm -eq 'Y') {
            gh secret delete $Name
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $Name deleted successfully" -ForegroundColor Green
            } else {
                Write-Host "❌ Failed to delete $Name" -ForegroundColor Red
            }
        } else {
            Write-Host "Cancelled" -ForegroundColor Gray
        }
    }
    
    "get" {
        Write-Host "⚠️  GitHub doesn't allow retrieving secret values for security reasons." -ForegroundColor Yellow
        Write-Host "   You can only check if a secret exists:" -ForegroundColor Gray
        gh secret list | Select-String $Name
    }
}

