Clear-Host

$TenantId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Subscription = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ResourceGroup = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Vault_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#$ResourceId = '/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
Connect-AzAccount -TenantId $TenantId -Credential $Credential -Subscription $Subscription -

New-AzKeyVault -Name $Vault_Name -ResourceGroupName $ResourceGroup -Location "East US" 
Set-AzKeyVaultAccessPolicy -VaultName $Vault_Name -UserPrincipalName $UserName -PermissionsToSecrets get,set,delete
$secretvalue = ConvertTo-SecureString "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -AsPlainText -Force
$secret = Get-AzKeyVaultSecret -VaultName $Vault_Name -Name "ExamplePassword" -SecretValue $secretvalue
$secret
#$AZ_Key_Vault_Secret = Get-AzKeyVaultSecret -VaultName $Vault_Name -Name "ExamplePassword" -AsPlainText -ResourceId $ResourceId
