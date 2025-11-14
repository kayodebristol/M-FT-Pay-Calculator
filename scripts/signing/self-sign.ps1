$cert = New-SelfSignedCertificate `
  -Type CodeSigningCert `
  -Subject "CN=Plures LLC Code Signing" `
  -KeyExportPolicy Exportable `
  -KeySpec Signature `
  -KeyAlgorithm RSA `
  -KeyLength 4096 `
  -HashAlgorithm SHA256 `
  -CertStoreLocation "Cert:\CurrentUser\My"

$pwd = Read-Host -AsSecureString "Enter password for PFX"
Export-PfxCertificate `
  -Cert $cert `
  -FilePath "scripts/signing/plures-code-signing.pfx" `
  -Password $pwd
