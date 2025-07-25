Clear-Host
Function Get_AZ_DEVOPS_URL() {
    Param(
        [string]$Organization_URL, 
        [hashtable]$Header, 
        [string]$CoreAreaId
    )
    # Resource Area ids

    # Build the URL for calling the Organization level Resource Area Ids REST API for the RM APIs
    $OrganizationResourceAreasUrl = [string]::Format("{0}/_apis/resourceAreas/{1}?api-preview=5.0-preview.1", $Organization_URL, $CoreAreaId)

    # Do a GET on this URL (this returns an object with a "locationUrl" field)
    $Results = Invoke-RestMethod -Uri $OrganizationResourceAreasUrl -Headers $Header

    # The "locationUrl" field reflects the correct base URL for RM REST API calls
    if ("null" -eq $Results) {
        $AreaUrl = $Organization_URL
    }
    else {
        $AreaUrl = $Results.locationUrl
    }
    return $AreaUrl
}


$Organization_URL = "https://xxxxxxxxxxxxxxxxxxxx"

$Personal_Azure_Token = "Enter Your PAT Here"

Write-Host "Initializing Authentication to Azure DevOps" -ForegroundColor Yellow
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Header = @{authorization = "Basic $Token"}
$Project = "xxxxxxxxxxxxxxxxxxxx"
$Project_ID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$BuildAreaId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$TFS_BaseUrl = Get_AZ_DEVOPS_URL -Organization_URL $Organization_URL -Header $Header -CoreAreaId $BuildAreaId

$CSV_Path = "C:\Users\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.csv"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)
Write-Host "Initializing Invoke-RestMethod to Azure DevOps for all Build IDs imported from the CSV." -ForegroundColor Yellow
ForEach ($V in $Values) {
    IF ($null -ne $CSV_Data[$v]) {
        $DefinitionId = $CSV_Data[$V].DefinitionId
        $DefinitionName = $CSV_Data[$V].DefinitionName
        $DefinitionPath = $CSV_Data[$V].DefinitionPath #>

        # Good Definition ID Example that shows all of the contingencies.
        #$DefinitionId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        # https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx?api-version=5.1
        $Build_Definitions_Url = "$TFS_BaseUrl/$Project/_apis/build/definitions/$DefinitionId`?api-version=5.1"
        $RestMethod_Error1 = $null
        $RestMethod_Error2 = $null
        
        $finishTime_URL = "$TFS_BaseUrl/$Project/_apis/build/builds?api-version=6.1-preview.6&definitions=$DefinitionId&queryOrder=finishTimeDescending&`$top=1"
        
        try{$finishTime_response = (Invoke-RestMethod -Uri $finishTime_URL -Method Get -ContentType "application/json" -Headers $Header)}
        catch { If ($null -ne  $_.Exception.Message) { 
            $RestMethod_Error1 = $_.Exception.Message
            $finishTime_response = $null
            }
        }
        try{$Result = (Invoke-RestMethod -Uri $Build_Definitions_Url -Method Get -ContentType "application/json" -Headers $Header)}
        catch { If ($null -ne  $_.Exception.Message){
            $RestMethod_Error2 = $_.Exception.Message
            $Contingency1 = $null
            $Contingency2 = $null
            $Contingency3 = $null
            $Contingency4 = $null
            $Contingency5 = $null
            $Contingency6 = $null
            $Contingency7 = $null
            $Contingency8 = $null
            $Contingency9 = $null
            $Result = $null
            }
        }  
        # Contingencies
        If ($null -ne $finishTime_response) {
            $FinishTime = $finishTime_response.value.finishTime
        }
        If ($Result.process.phases.steps.displayName -match "Publish Artifact: xx") {
            $Contingency1 = ('displayName1 = Publish Artifact: xx')
        }
        If ($Result.process.phases.steps.displayName -match "Package xx - Setup Build") {
            $Contingency2 = ('displayName2 = Package xx - Setup Build')
        }
        If ($Result.process.phases.steps.inputs.PathtoPublish -contains '$(Build.ArtifactStagingDirectory)\xx') {
            $Contingency3 = ('PathtoPublish = $(Build.ArtifactStagingDirectory)\\xxx')
        }
        If ($Result.process.phases.steps.inputs.TargetPath -contains '$(xxxxxxxxxxxxxxxxxxxx)') {
            $Contingency4 = ('TargetPath = $(xxxx)')
        }
        If ($Result.process.phases.steps.inputs.ArtifactType -match "FilePath") {
            $Contingency5 = ('ArtifactType = FilePath')
        }
        If ($Result.process.phases.steps.inputs.ArtifactName -match "AP") {
            $Contingency6 = ('ArtifactName = xx')
        }
        If ($Result.process.phases.steps.task.id -match "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {
            $Contingency7 = ('Task.ID1 = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        }
        If ($Result.process.phases.steps.task.id -match "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") {
            $Contingency8 = ('Task.ID2 = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        }
        If ($Result.process.phases.steps.inputs.useDfs -match "true") {
            $Contingency9 = ('xxxx = true')
        }
        $Object_X = New-Object PSObject -Property @{
        "Build Name" = $DefinitionName
        "Build ID" = $DefinitionId
        "Definition Path" = $DefinitionPath
        #"Project Name" = $Result.project.name
        "Project Name" = $Project
        # "Project ID" = $Result.project.id
        "Project ID" = $Project_ID
        "RestMethod_Error1" = $RestMethod_Error1
        "RestMethod_Error2" = $RestMethod_Error2
        "FinishTime" = $FinishTime
        "Contingency1" = $Contingency1
        "Contingency2" = $Contingency2
        "Contingency3" = $Contingency3
        "Contingency4" = $Contingency4
        "Contingency5" = $Contingency5
        "Contingency6" = $Contingency6
        "Contingency7" = $Contingency7
        "Contingency8" = $Contingency8
        "Contingency9" = $Contingency9
        }
        $Object_X | Select-Object "Build ID", "Build Name", "Definition Path", "Project Name", "Project ID", "RestMethod_Error1", "RestMethod_Error2", "FinishTime",
        "Contingency1", "Contingency2","Contingency3", "Contingency4", "Contingency5", "Contingency6", "Contingency7", "Contingency8", "Contingency9"  | 
            Export-Csv -LiteralPath "C:\xxxxxxxxxxxxxxxxxxxxServices.csv" -NoTypeInformation -Encoding utf8 -NoClobber -Append -Force #>
    }
}
