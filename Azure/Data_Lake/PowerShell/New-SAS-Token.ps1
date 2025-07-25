Clear-Host

## Generate SAS Token ##
# Guide
# https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-user-delegation-sas-create-powershell

$TenantId = "xxxxx-xxxxx-xxxxxx-xxxxx"
$Subscription = "xxxxx-xxxxx-xxxxxx-xxxxx"

$Storage_Account_Name = 'Storage_Account_Name'
$Container = 'Container'

# uncomment and comment out the other same name varriable to use a stored Credential if wanting to go that route.
# $Azure_PassWord = Read-Host "Please enter your Azure Account" 
$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password

$UserName = "username@company.com"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)

Connect-AzAccount -TenantId $TenantId -Credential $Credential
Set-AzContext -Subscription $Subscription
$AzStorageContext = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

# SAS_Token is the SAS Token that will be used carrying forward.
# Permission RWD = Read, Write, Delete
$SAS_Token = (New-AzStorageContainerSASToken -Context $AzStorageContext -Name $Container -Permission 'RWD')
