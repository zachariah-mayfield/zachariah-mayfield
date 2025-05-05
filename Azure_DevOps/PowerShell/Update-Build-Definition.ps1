Clear-Host
$Organization_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Personal_Azure_Token = "Enter your PAT here"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$definitionId = "Build definitionId Number"
$PUT_URL = "$Organization_URL/$Project/_apis/build/definitions/$definitionId`?api-version=6.1-preview.7"
$GET_URL = "$Organization_URL/$Project/_apis/build/definitions/$definitionId`?api-version=5.1"

# This sets the $Json variable to the JSON Build Definition of the $definitionId.
$json = Invoke-RestMethod -Uri $GET_URL -Method Get -ContentType "application/json" -Headers $Headers

# This will update ANY existing Propety that is in an array and matches the "Where-Object" $displayName. 
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).task | 
Add-Member -NotePropertyName "id" -NotePropertyValue "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -Force 

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).task | 
Add-Member -NotePropertyName "versionSpec" -NotePropertyValue '0.*' -Force 

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "dropServiceURI" -NotePropertyValue "https://microsoft.artifacts.visualstudio.com/DefaultCollection" -Force 

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "buildNumber" -NotePropertyValue '$(System.TeamProject)/$(Build.Repository.Name)/$(Build.BuildNumber)-$(Build.SourceBranchName)' -Force 

# This will add a new Property and set the value for the filtered Step[] to that of the old json value.
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "sourcePath" -NotePropertyValue (($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: AP"}).inputs.PathtoPublish) -Force

# This will add a new Property and set the value to $null for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "dropExePath" -NotePropertyValue "" -Force 

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "toLowerCase" -NotePropertyValue "true" -Force 

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "detailedLog" -NotePropertyValue "false" -Force  

# This will add a new Property and set the value for the filtered Step[].
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "retentionDays" -NotePropertyValue "180" -Force 

# This will add a new Property and set the value for the filtered Step[] to that of the old json value.
($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs | 
Add-Member -NotePropertyName "dropMetadataContainerName" -NotePropertyValue (($json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"}).inputs.ArtifactName) -Force

# This line has to be last because it is based off of the | Where-Object {$_.displayName -match "Publish Artifact: xx"} filter. 
$json.process.phases.steps | Where-Object {$_.displayName -match "Publish Artifact: xx"} | 
Add-Member -NotePropertyName "displayName" -NotePropertyValue "Publish to Artifact Services Drop" -Force 

# This filters out the Step[] where task.id is equal to: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" and returns everything that is NOT EQUAL to it. 
$newSteps = ($json.process.phases.steps | Where-Object {$_.task.id -ne "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"})

# This sets the Phases[] to the newly filtered Step[].
$json.process.phases[0].steps = $newSteps

# This is the Body of the Web Request. it is all of the modified $json.
$PutData = $($json | ConvertTo-Json -Compress -Depth 100)

# This run the PUT command for Updating a Build Definition, with the newly modified JSON file.
Invoke-RestMethod -Uri $PUT_URL -Method Put -Body $PutData -ContentType "application/json" -Headers $Headers
