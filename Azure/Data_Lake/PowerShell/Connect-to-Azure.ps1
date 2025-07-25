Clear-Host

$ResourceGroup = "xxxxxx"

$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "xxx.com"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)

$TenantId = "xxxxxxxxxxxxxxxxxxxxxxx"
$Subscription = "xxxxxxxxxxxxxxxxxx"

Connect-AzAccount -TenantId $TenantId -Credential $Credential

Set-AzContext -Subscription $Subscription

Import-AzAksCredential -ResourceGroupName $ResourceGroup -Name 'xxxxxxxxxx' -Force

.\kubectl get nodes

# Disconnect-AzAccount -Username $UserName
