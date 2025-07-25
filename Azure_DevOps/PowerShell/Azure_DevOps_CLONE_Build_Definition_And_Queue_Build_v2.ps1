Clear-Host
$Organization_URL = "https://xxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$definitionId = "xxxxxx"
$DefinitionToCloneId = "xxxxxxxxxxxxx"
$POST_URL = "$Organization_URL/$Project/_apis/build/definitions?definitionToCloneId=$DefinitionToCloneId&api-version=6.1-preview.7"
$GET_URL = "$Organization_URL/$Project/_apis/build/definitions/$definitionId`?api-version=5.1"

# This sets the $Json variable to the JSON Build Definition of the $definitionId.
$json = Invoke-RestMethod -Uri $GET_URL -Method Get -ContentType "application/json" -Headers $Headers

# New Clone $json Name
$json.Name = $json.Name + "_xxxxxxx"

# This filters out the Step[] where task.id is equal to: "xxxxxxxxxxxxxxxxxxxxx" and returns everything that is NOT EQUAL to it. 
$newSteps = ($json.process.phases.steps | Where-Object {$_.task.id -ne "xxxxxxxxxxxxxxxxxxxxxxxx"})

# This sets the Phases[] to the newly filtered Step[].
$json.process.phases[0].steps = $newSteps
for ($i = 0; $i -lt $json.process.phases.steps.Length; $i++){    
    $step = $json.process.phases.steps[$i]    
    if ($step.task.id -match "xxxxxxxxxxxxxxxxxxx" -and $step.inputs.TargetPath.Contains("xxxxxxxxxxxxxxx"))    {            
        $jsonTemplate =  "{"+        
        "  `"environment`": {},"+        
        "  `"enabled`": true,"+        
        "  `"continueOnError`": false,"+        
        "  `"alwaysRun`": false,"+        
        "  `"displayName`": `"Publish to Artifact Services Drop`","+        
        "  `"timeoutInMinutes`": 0,"+        
        "  `"condition`": `"succeeded()`","+        
        "  `"task`": {"+        
        "  `"id`": `"xxxxxxxxxxxxxxxx`","+        
        "  `"versionSpec`": `"0.*`","+        
        "  `"definitionType`": `"task`""+        
        "  },"+        
        "  `"inputs`": {"+        
        "    `"dropServiceURI`": `"https://xxxxxxxxxxxxxxx`","+        
        "    `"buildNumber`": `"`$(System.TeamProject)/`$(Build.Repository.Name)/`$(Build.BuildNumber)-`$(Build.SourceBranchName)`","+        
        "    `"sourcePath`": `"`","+        
        "    `"dropExePath`": `"`","+        
        "    `"toLowerCase`": `"true`","+        
        "    `"detailedLog`": `"false`","+        
        "    `"usePat`": `"false`","+        
        "    `"retentionDays`": `"180`","+        
        "    `"dropMetadataContainerName`": `"`""+        
        "    }"+        
        "  }" | ConvertFrom-Json        
        $jsonTemplate.inputs.sourcePath = $step.inputs.PathtoPublish
        $jsonTemplate.inputs.dropMetadataContainerName = $step.inputs.ArtifactName
        if (-not [string]::IsNullOrEmpty($step.displayName)){            
            $jsonTemplate.displayName = $step.displayName
        }
        Write-Host "Processing $i"        
        $json.process.phases[0].steps.SetValue($jsonTemplate, $i)
    }
}

# This is the Body of the Web Request. it is all of the modified $json.
$POST_Data = $($json | ConvertTo-Json -Compress -Depth 100)

# This run the POST command for Creating a new Build Definition, with the newly modified JSON file.
$New_Clone = Invoke-RestMethod -Uri $POST_URL -Method POST -Body $POST_Data -ContentType "application/json" -Headers $Headers

$Clone_Build_DefinitionId = $New_Clone.id

$Clone_Build_DefinitionId
