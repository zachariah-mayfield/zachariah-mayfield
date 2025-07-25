Clear-Host
$Organization_URL = "https://xxxxxxxxx"
$Project = "xxxxxxxxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$definitionId = "xxxxxxx" #buildId=xxxxx #&`$top=1
$GET_URL = "$Organization_URL/$Project/_apis/build/latest/$definitionId`?api-version=6.0-preview.1"
$Response = Invoke-RestMethod -Uri $GET_URL -Method GET -ContentType "application/json" -Headers $Headers
$artifactName = "xxxxxxxx"
$buildId = $Response.id
$GET_URL2 =  "$Organization_URL/$Project/_apis/build/builds/$buildId/artifacts?artifactName=$artifactName&api-version=6.1-preview.5"
$Result = Invoke-RestMethod -Uri $GET_URL2 -Method GET -ContentType "application/json" -Headers $Headers
$Download_URL = $Result.resource.downloadUrl

New-Item -ItemType "directory" -Path "C:\ZipFolder" -ErrorAction SilentlyContinue
$ZipFile = "C:\ZipFolder\Artifact.zip"
$Destination= "C:\Extracted\"

Invoke-WebRequest -Uri $Download_URL -Headers $Headers -Method Get -ContentType "application/zip" -OutFile $ZipFile 
Expand-Archive -Path $ZipFile -DestinationPath $Destination -Force
$Destination_File = ($Result.resource.data.split("/") | Select-Object -Last 1)
Start-Process $Destination\$Destination_File\VSTSDrop.json
