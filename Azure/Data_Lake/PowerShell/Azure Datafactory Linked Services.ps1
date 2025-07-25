Clear-Host
# $ADFs = ((((az datafactory list | Select-String "name" -CaseSensitive) -replace '"name": ','') -replace '"','') -replace ',','') 

Clear-Host
#$startTime = (Get-Date)
$FormatEnumerationLimit=-1
# Step 1. Create Certificate
# New-SelfSignedCertificate -Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -CertStoreLocation "Cert:\LocalMachine" -KeyExportPolicy 'Exportable' -KeySpec 'Signature' `
# -KeyDescription 'Certificate for Authenicating to Azure Edav Dev' -KeyAlgorithm 'RSA' -KeyLength 2048 -NotAfter (Get-Date).AddYears(5) 
# Start-Process 'C:\Program Files (x86)\Microsoft Azure Storage Explorer\StorageExplorer.exe' -ArgumentList '-ignore-certificate-errors'

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
If ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

$Environment = 'Development'  

IF ($Environment -eq 'Development') {
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Cert:\LocalMachine\root\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
ElseIF ($Environment -eq 'Production') {
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Cert:\LocalMachine\root\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
Else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}

# Connect to Azure with system-assigned managed identity
#$Connect_AzAccount = Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Application_ID -Tenant $Tenant_ID -CertificateThumbprint $Certificate_Thumbprint 

$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "$($env:username)@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$PSCredential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)

$Connect_AzAccount = Connect-AzAccount -Credential $PSCredential -Subscription $Subscription_ID -Tenant $Tenant_ID

# Set and store AZ context
$AzContext = (Set-AzContext -SubscriptionName $Connect_AzAccount.Context.Subscription.Name -DefaultProfile $Connect_AzAccount) 

$ADFs = Get-AzDataFactoryV2 -ResourceGroupName 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' <#'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'#> -DefaultProfile $AzContext

$CSV_File_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxServices.csv'

ForEach ($ADF in $ADFs) {
    $ADF_Linked_Services = Get-AzDataFactoryV2LinkedService -ResourceGroupName 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -DataFactoryName $ADF.DataFactoryName 
    ForEach ($Linked_Service in $ADF_Linked_Services) {
        $Linked_Service | Select-Object -Property Name, ResourceGroupName, DataFactoryName, Properties | Export-Csv -Path ".\$($CSV_File_Name)" -NoTypeInformation -Append -Force
    }
}
