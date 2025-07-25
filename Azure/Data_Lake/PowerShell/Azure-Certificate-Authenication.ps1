Clear-Host

# Resource::

#  Create Certificate
New-SelfSignedCertificate -Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -CertStoreLocation "Cert:\LocalMachine" -KeyExportPolicy 'Exportable' -KeySpec 'Signature' -KeyDescription 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -KeyAlgorithm 'RSA' -KeyLength 2048 -NotAfter (Get-Date).AddYears(5) 



IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

# This variable sets the Current working Azure Enviorment.
#$Azure_Enviorment = 'Development'
#$Azure_Enviorment = 'Production'

$Azure_Enviorment = 'Production'

If ($Azure_Enviorment -eq 'Development') {
    $Tenant_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint
}
elseif ($Azure_Enviorment -eq 'Production') {
    $Tenant_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' 
    $Application_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint
}
else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Enviorment variable not set'
    Exit-PSHostProcess
}

# This connects to Azure with the supplied parameters.
Connect-AzAccount -Subscription $Subscription_Id -ApplicationId $Application_Id -Tenant $Tenant_Id -CertificateThumbprint $CertificateThumbprint | Out-Null

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

# This sets the max blob returns
$MaxReturn = 10000

# This sets the $Token variable to null so that the do while can run a loop until $token in no longer null.
$Token = $Null

# This will loop through the $Container_Name and return all of the Blobs and the container name.
Do {
    $Blobs = Get-AzStorageBlob -Context $Azure_Storage_Context -Container $Container_Name -MaxCount $MaxReturn -ContinuationToken $Token
    IF ($Blobs.Length -le 0) { Break;}
    $Token = $Blobs[$blobs.Count -1].ContinuationToken;
}
While ($null -ne $Token)

Write-Host -ForegroundColor Yellow "Container Name: $($Container_Name)"
Write-Host -ForegroundColor Yellow "Blob Name: $($Blobs.Name)"
