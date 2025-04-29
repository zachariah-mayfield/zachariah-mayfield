Clear-host
$URL_NEXT_Count = $null
$URL_LAST_Count = $null
$ALL_Results = $null
$GitHub_Win_Cred_UserName = (Get-StoredCredential -Target 'GitHub' -Type Generic -AsCredentialObject).UserName
$GitHub_Win_Cred_PassWord = (Get-StoredCredential -Target 'GitHub' -Type Generic -AsCredentialObject).Password
$Credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($GitHub_Win_Cred_UserName), $($GitHub_Win_Cred_PassWord))))
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add('Authorization', "Basic $Credentials")
$Header.Add('Accept','application/vnd.github.v3+json')
$GitHub_Instance = 'carmax'

$RegEX_1 = ('(?<=page=)(\d)(?=>;\s*rel="next")')
$RegEX_2 = ('(?<=page=)(\d)(?=>;\s*rel="last")')

$Teams_GitHub_URL = "https://github.$($GitHub_Instance).com/api/v3/orgs/$($GitHub_Instance)/teams?per_page=100"
$Responses_1 = (Invoke-WebRequest -Uri $Teams_GitHub_URL -Method GET -Headers $Header)

$First_Results = ($Responses_1.Content| ConvertFrom-Json).name

[int]$URL_NEXT_Count = ( ([regex]::Match(($Responses_1.Headers.Link),$RegEX_1).Groups[1].Value) )
[int]$URL_LAST_Count = ( ([regex]::Match(($Responses_1.Headers.Link),$RegEX_2).Groups[1].Value) )

$ALL_Results = @()
DO {
    $Next_URL = "https://github.$($GitHub_Instance).com/api/v3/organizations/99/teams?per_page=100&page=$($URL_NEXT_Count)"
    $Results = (Invoke-WebRequest -Uri $Next_URL -Method GET -Headers $Header)
    $URL_NEXT_Count++
    $ALL_Results += ($Results.Content | ConvertFrom-Json).name
} 
Until  ($URL_NEXT_Count -gt $URL_LAST_Count)

$All_GitHubTeams = ($First_Results + $ALL_Results)
$All_GitHubTeams
Write-Host -ForegroundColor Cyan $All_GitHubTeams.Count 'Total GitHub Teams'
