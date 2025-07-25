<#
.SYNOPSIS
    Retrieves a CyberArk object using API and certificate-based authentication.

.PARAMETER CyberArk_AppID
    The App ID in CyberArk.

.PARAMETER CyberArk_Safe
    The Safe in CyberArk.

.PARAMETER CyberArk_Object
    The Account Name or Object in CyberArk.

.EXAMPLE
    .\Get-CyberArkObject.ps1 -CyberArk_AppID "MyAppID" -CyberArk_Safe "MySafe" -CyberArk_Object "MyObject"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$CyberArk_AppID,

    [Parameter(Mandatory=$true)]
    [string]$CyberArk_Safe,

    [Parameter(Mandatory=$true)]
    [string]$CyberArk_Object
)

# Suppress SSL warnings
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Certificate and Key Location
# NOTE: PowerShell prefers a .pfx file. Convert PEM/KEY to PFX if needed.
$CertPath = "./path/to/client.pfx"

# Load certificate
try {
    $Cert = Get-PfxCertificate -FilePath $CertPath
} catch {
    Write-Error "Could not load certificate from path: $CertPath"
    exit 1
}

# Function to get CyberArk Object
function Get-CyberArkObject {
    param (
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert,
        [string]$CyberArk_AppID,
        [string]$CyberArk_Safe,
        [string]$CyberArk_Object
    )

    $CyberArk_API_URL = "https://your-cyberark-instance/api/Accounts"
    $uri = "$CyberArk_API_URL?AppID=$CyberArk_AppID&Safe=$CyberArk_Safe&Object=$CyberArk_Object"

    $headers = @{
        "Content-Type" = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -Certificate $Cert -SkipCertificateCheck
    } catch {
        Write-Error "Error calling CyberArk API: $_"
        exit 1
    }

    return @(
        @{ UserName = $response.UserName },
        @{ Password = $response.Content }
    )
}

# Main logic
$CyberArk_Object = Get-CyberArkObject -Cert $Cert `
                                      -CyberArk_AppID $CyberArk_AppID `
                                      -CyberArk_Safe $CyberArk_Safe `
                                      -CyberArk_Object $CyberArk_Object

$UserName = $CyberArk_Object[0].UserName
$Password = $CyberArk_Object[1].Password

Write-Host "`nCyberArk Object Retrieved Successfully:"
Write-Host "---------------------------------------"
Write-Host "UserName: $UserName"
Write-Host "Password: $Password"

