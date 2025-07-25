Clear-Host

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

# This variable sets the Current working Azure Environment.
#$Azure_Enviorment = 'Development'
#$Azure_Enviorment = 'Production'

$Azure_Environment = 'Production'

If ($Azure_Environment -eq 'Development') {
    $Tenant_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=xxxxx"}).Thumbprint
}
elseif ($Azure_Environment -eq 'Production') {
    $Tenant_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' 
    $Application_Id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=xxxxx"}).Thumbprint
}
else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}

# This connects to Azure with the supplied parameters.
Connect-AzAccount -Subscription $Subscription_Id -ApplicationId $Application_Id -Tenant $Tenant_Id -CertificateThumbprint $CertificateThumbprint | Out-Null

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

$Source = 'C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

$Tableau_Files = (Get-childitem -Path $Source | Where-Object {$_.Name -like "*.tsbak"})

ForEach ($TB_File in $Tableau_Files) {
    Try {
        Set-AZStorageBlobContent -Context $Azure_Storage_Context -File $TB_File.fullname -Container $Container_Name -Force -verbose -ErrorAction Stop
    }
    Catch {
        Exit-PSHostProcess
    }
    Write-Output "Removing file: $($TB_File.fullname)" | Out-File -FilePath "C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.txt" -NoClobber -Append -Force
    Remove-Item -Path $TB_File.fullname -Force -verbose
}
