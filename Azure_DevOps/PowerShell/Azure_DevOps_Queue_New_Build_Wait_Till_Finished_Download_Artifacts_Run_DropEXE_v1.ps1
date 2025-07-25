Clear-Host
$Organization_URL = "https://xxxxxxxxxxxx"
$Project = "xxxxxxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$definitionId = "xxxx" 
$GET_URL = "$Organization_URL/$Project/_apis/build/latest/$definitionId`?api-version=6.0-preview.1"
$First_Response = Invoke-RestMethod -Uri $GET_URL -Method GET -ContentType "application/json" -Headers $Headers

# Getting the original buildId before starting 
$Original_BuildId = $First_Response.id

# Creating the POST URL to start the Build Queue 
$ignoreWarnings = $true
$POST_URL = "$Organization_URL/$Project/_apis/build/builds?ignoreWarnings=$ignoreWarnings&definitionId=$definitionId&api-version=6.1-preview.6" 

# Start the Queue of the new build.
Invoke-RestMethod -Uri $POST_URL -Method POST -ContentType "application/json" -Headers $Headers

# Getting the Current buildId to see if it matches the Original buildId.
$Second_Response = Invoke-RestMethod -Uri $GET_URL -Method GET -ContentType "application/json" -Headers $Headers
$Current_buildId = $Second_Response.id

# Waiting for the new build to complete.
while ($Current_buildId -eq $Original_BuildId) {
    $Current_buildId = $null
    $Second_Response = Invoke-RestMethod -Uri $GET_URL -Method GET -ContentType "application/json" -Headers $Headers
    $Current_buildId = $Second_Response.id
    Write-Host -ForegroundColor Cyan "New build has started, but is not complete yet. Waiting 15 seconds and will check again."
    Start-Sleep -Seconds 15
}

# Get the VSTS Drop JSON Download URL
IF ($Current_buildId -ne $Original_BuildId) {
    $artifactName = "xxx"
    $GET_URL2 =  "$Organization_URL/$Project/_apis/build/builds/$Current_buildId/artifacts?artifactName=$artifactName&api-version=6.1-preview.5"
    $Result = Invoke-RestMethod -Uri $GET_URL2 -Method GET -ContentType "application/json" -Headers $Headers
    $Vsts_Download_URL = $Result.resource.downloadUrl
}

# Create the directories to use for the Zip File and extracted Zip files.
New-Item -ItemType "directory" -Path "C:\xxxxxxxxxxxxxxx\$definitionId" -ErrorAction SilentlyContinue
$ZipFile = "C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\$definitionId`\$definitionId`_Artifact.zip"
$Destination = "C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\$definitionId`\"

# Download and Extract the VSTS Drop JSON from the URL.
Invoke-WebRequest -Uri $Vsts_Download_URL -Headers $Headers -Method Get -ContentType "application/zip" -OutFile $ZipFile 
Expand-Archive -Path $ZipFile -DestinationPath $Destination -Force
$Destination_File = ($Result.resource.data.split("/") | Select-Object -Last 1)
$Zipped_JSON = (Get-Content -Path $Destination\$Destination_File\VSTSDrop.json | ConvertFrom-Json -Depth 100)
$Azure_Artifacts_Drop_URL = $Zipped_JSON.VstsDropBuildArtifact.VstsDropUrl

# Your AzDevOps Organization account name is the first component of your custom dev.azure.com URL
$account = "xxxxxxxx" 
$DropEXE = [System.IO.Path]::Combine($env:TEMP, "Drop.App", "lib", "net45", "drop.exe")

# Check if Drop.EXE exists
if (!(Test-Path $dropExe)) {
    throw [System.Exception] "Cannot find drop.exe. This script must be placed in the same directory as drop.exe." 
    # Download the client from your AzDevOps account to TEMP/Drop.App/lib/net45/drop.exe
    $sourceUrl = "https://artifacts.dev.azure.com/$account/_apis/drop/client/exe"
    $destinationZip = [System.IO.Path]::Combine($env:TEMP, "Drop.App.zip")
    $destinationDir = [System.IO.Path]::Combine($env:TEMP, "Drop.App")
    $destinationExe = [System.IO.Path]::Combine($destinationDir, "lib", "net45", "drop.exe")
    $webClient = New-Object "System.Net.WebClient"
    $webClient.Downloadfile($sourceUrl, $destinationZip)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($destinationZip, $destinationDir)
    Write-Host $destinationExe
}

$DropURI = $Azure_Artifacts_Drop_URL
$DownloadDir = $Destination

# Invoke drop.exe in streaming mode
$dropArgs = 'get'
$dropArgs += ' -u '
$dropArgs += $DropUri
$dropArgs += ' -d '
$dropArgs += $DownloadDir
$dropArgs += ' --alwaysCaptureCtrlC' #
$dropArgs += ' --streaming' #
$dropArgs += ' --streamingintervalseconds ' #
$dropArgs += 60
$dropArgs += ' ' + $ExtraDropExeArgs

# This is creating and compiling the command to run the Drop.EXE
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $dropExe
$psi.UseShellExecute = $false # Must set this to false so that the spawned process is of the same process group as the PS shell.
$psi.Arguments = $dropArgs
$psi.WorkingDirectory = $scriptDir

# This will run the Drop.EXE with all of the arguments. 
[System.Console]::TreatControlCAsInput = $true
$proc = [System.Diagnostics.Process]::Start($psi)
$proc
