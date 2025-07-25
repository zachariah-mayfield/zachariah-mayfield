Clear-Host

IF ($PSVersionTable.PSVersion.Major -lt "7") {
	Write-Host -ForegroundColor Yellow	"Please update your version of powershell to the latest version."
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	"Inorder to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:" ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

$TenantId = "xxxxx-xxxxx-xxxxxx-xxxxx"
$Subscription = "xxxxx-xxxxx-xxxxxx-xxxxx"
$Storage_Account_Name = 'Storage_Account_Name'

#Try This filter if the other dosent work "/Database/"
$Prefix = 'Database/'

#$AzStorageContainer = 'xxx'

#$Azure_PassWord = Read-Host "Please enter your Azure Account Password" 
$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "username@Company.xxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
Connect-AzAccount -Credential $Credential -Subscription $Subscription -Tenant $TenantId
$AzStorageContext = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

$AzStorageContainers = ((Get-AZStorageContainer -Context $AzStorageContext ) | Where-Object {$_.Name -like "dd*" -or $_.Name -like "od*"})

$Blob_Owner = 'xxx'

$Owner = (Get-AzADServicePrincipal -DisplayName $Blob_Owner)

ForEach ($AzStorageContainer in $AzStorageContainers.name) {
    Update-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $AzStorageContainer -Path 'Database/' -Owner $Owner.Id -Permission 'rwxrwxrwx' -Verbose
}
