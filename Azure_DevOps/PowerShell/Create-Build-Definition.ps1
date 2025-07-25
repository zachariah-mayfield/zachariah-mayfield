Clear-Host

$json = (Get-Content -LiteralPath "C:\Users\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.json")

$Organization_URL = "https://dev.azure.com/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Personal_Azure_Token = "Enter Your PAT Here"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Header = @{authorization = "Basic $Token"}

$Url = "$Organization_URL/$Project/_apis/build/definitions?api-version=6.1-preview.7"

#Create New Build Definition

Invoke-RestMethod -Uri $Url -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType "application/json" -Headers $Header
