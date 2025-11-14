# Windows Code Signing Script
# Signs MSI installers using a code signing certificate

param(
    [Parameter(Mandatory=$true)]
    [string]$MsiPath,
    
    [Parameter(Mandatory=$false)]
    [string]$CertificatePath = $env:WINDOWS_SIGNING_CERTIFICATE_PATH,
    
    [Parameter(Mandatory=$false)]
    [string]$CertificatePassword = $env:WINDOWS_SIGNING_CERTIFICATE_PASSWORD,
    
    [Parameter(Mandatory=$false)]
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

if (-not (Test-Path $MsiPath)) {
    Write-Error "MSI file not found: $MsiPath"
    exit 1
}

if (-not $CertificatePath -or -not (Test-Path $CertificatePath)) {
    Write-Error "Certificate file not found: $CertificatePath"
    Write-Host "Set WINDOWS_SIGNING_CERTIFICATE_PATH environment variable or provide -CertificatePath"
    exit 1
}

Write-Host "Signing MSI: $MsiPath"
Write-Host "Using certificate: $CertificatePath"

# Use signtool to sign the MSI
$signtool = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"

if (-not (Test-Path $signtool)) {
    # Try alternative locations
    $signtool = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Windows Kits\10\bin" -Filter "signtool.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    
    if (-not $signtool) {
        Write-Error "signtool.exe not found. Please install Windows SDK."
        exit 1
    }
}

try {
    if ($CertificatePassword) {
        & $signtool sign /f $CertificatePath /p $CertificatePassword /t $TimestampServer /v $MsiPath
    } else {
        & $signtool sign /f $CertificatePath /t $TimestampServer /v $MsiPath
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully signed: $MsiPath"
        
        # Verify signature
        & $signtool verify /pa /v $MsiPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Signature verified successfully"
        } else {
            Write-Warning "Signature verification failed"
        }
    } else {
        Write-Error "Signing failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Error during signing: $_"
    exit 1
}

