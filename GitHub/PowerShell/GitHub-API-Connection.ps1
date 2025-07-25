Clear-Host



#$GitHub_Win_Cred_UserName = (Get-StoredCredential -Target 'GitHub_Pat' -Type Generic -AsCredentialObject).UserName
$GitHub_Win_Cred_PassWord = (Get-StoredCredential -Target 'GitHub_Pat' -Type Generic -AsCredentialObject).Password
#$Credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($GitHub_Win_Cred_UserName), $($GitHub_Win_Cred_PassWord))))
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add('Authorization', "Token $GitHub_Win_Cred_PassWord")
#$Header.Add('Authorization', "Basic $Credentials") 
#$Header.Add('Accept','application/json')
$Header.Add('Accept','application/vnd.github.v3+json')
$GitHub_Instance = 'GitHub_Instance'

$GitHub_Repo_Url = "https://api.github.com/repos/$($GitHub_Instance)/"

$GitHub_Repo_Name = "GitHub_Repo_Name"

$GitHub_URL = $GitHub_Repo_Url + $GitHub_Repo_Name

$Repository = (Invoke-RestMethod -Uri $GitHub_URL -Method GET -Headers $Header)

$Repository 