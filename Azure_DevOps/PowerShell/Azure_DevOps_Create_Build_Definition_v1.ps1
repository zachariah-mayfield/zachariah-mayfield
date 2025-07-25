Clear-Host

$json = (Get-Content -LiteralPath "C:\xxxxxxxx.json")

$Organization_URL = "https://xxxxxxxxxxxxxxx"
$Project = "xxxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Header = @{authorization = "Basic $Token"}

$Url = "$Organization_URL/$Project/_apis/build/definitions?api-version=6.1-preview.7"

#Create New Build Definition

Invoke-RestMethod -Uri $Url -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType "application/json" -Headers $Header
