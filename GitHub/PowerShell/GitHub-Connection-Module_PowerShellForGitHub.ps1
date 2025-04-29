Clear-Host



$GitHub_Win_Cred_UserName = (Get-StoredCredential -Target 'GitHub_Pat' -Type Generic -AsCredentialObject).UserName
$GitHub_Win_Cred_PassWord = (Get-StoredCredential -Target 'GitHub_Pat' -Type Generic -AsCredentialObject).Password
#$Credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($GitHub_Win_Cred_UserName), $($GitHub_Win_Cred_PassWord))))

[pscredential]$Pscredential = New-Object System.Management.Automation.PSCredential ($GitHub_Win_Cred_UserName, $GitHub_Win_Cred_PassWord)

Set-GitHubAuthentication -Credential ($GitHub_Win_Cred_UserName, $GitHub_Win_Cred_PassWord)
# Set-GitHubConfiguration -SuppressTelemetryReminder

$Repos = (Get-GitHubRepository -Visibility All).full_name

$Repos

