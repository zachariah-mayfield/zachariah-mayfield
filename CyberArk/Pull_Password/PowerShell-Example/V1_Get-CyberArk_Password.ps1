# Suppress SSL warnings
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Parse arguments
param(
    [string]$CyberArk_AppID,
    [string]$CyberArk_Safe,
    [string]$CyberArk_Object
)

# Certificate and Key Location
$CertPath = "./path/to/client.pem"
$KeyPath = "./path/to/client.key"
$CertAndKeyLocation = @($CertPath, $KeyPath)

# Load certificate (PowerShell expects a .pfx usually, not PEM/KEY split. This may require conversion.)
# Assuming you have a PFX certificate for use
$Cert = Get-PfxCertificate -FilePath "./path/to/client.pfx"

# Function to get CyberArk Object
function Get-CyberArkObject {
    param (
        [string[]]$CertAndKeyLocation,
        [string]$CyberArk_AppID,
        [string]$CyberArk_Safe,
        [string]$CyberArk_Object
    )

    # Set parameters
    $params = @{
        AppID  = $CyberArk_AppID
        Safe   = $CyberArk_Safe
        Object = $CyberArk_Object
    }

    # API URL
    $CyberArk_API_URL = "https://your-cyberark-instance/api/Accounts"

    # Build the full URI with query params
    $uri = "$CyberArk_API_URL?AppID=$CyberArk_AppID&Safe=$CyberArk_Safe&Object=$CyberArk_Object"

    # Headers
    $headers = @{
        "Content-Type" = "application/json"
    }

    # Make the HTTPS GET request
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -Certificate $Cert -SkipCertificateCheck

    # Parse response
    $UserName = @{ UserName = $response.UserName }
    $Password = @{ Password = $response.Content }

    return @($UserName, $Password)
}

# Get CyberArk object
$CyberArk_Object = Get-CyberArkObject -CertAndKeyLocation $CertAndKeyLocation `
                                      -CyberArk_AppID $CyberArk_AppID `
                                      -CyberArk_Safe $CyberArk_Safe `
                                      -CyberArk_Object $CyberArk_Object

# Extract values
$UserName = $CyberArk_Object[0].UserName
$Password = $CyberArk_Object[1].Password

# Print
Write-Host "UserName: $UserName"
Write-Host "Password: $Password"


# PowerShell works better with .pfx certificates, so if you only have .pem and .key, you may need to convert them using OpenSSL:
# openssl pkcs12 -export -out client.pfx -inkey client.key -in client.pem
