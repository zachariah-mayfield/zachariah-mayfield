Clear-Host
$Organization_URL = "https://xxxxxxxxxxx"
$Project = "xxxxxxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$ignoreWarnings = $true

# The below 4 lines creates the CSV Object to work with each row line and cell.
$CSV_Path = "C:\Temp\xxxxxxxxx_.csv"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    $Original_Build_DefinitionId = $null
    $Original_Build_Definition_Name = $null
    $Original_Build_Definition_New_Build_Id = $null
    $Original_json = $null
    $Original_Error_Message = $null
    $Original_Build_Result = $null
    $Original_Build_Error_Reason = $null
    $Original_Error_Message2 = $null
    $Original_Build_Error_Section_Starting = $null
    $Original_Build_Error_Reason_Task = $null
    $Clone_Build_DefinitionId = $null
    $Clone_Build_Name = $null
    $Clone_Build_Id = $null
    $Clone_json = $null
    $Clone_Error_Message = $null
    $Clone_Build_Result = $null
    $Clone_Build_Error_Reason = $null
    $Clone_Error_Message2 = $null
    $Clone_Build_Error_Section_Starting = $null
    $Clone_Build_Error_Reason_Task = $null

    IF ($null -ne $CSV_Data[$v]) { 
        # This is the Build Definition Id pulled from the CSV.
        # $Clone_Build_DefinitionId = $CSV_Data[$V].Clone_Build_DefinitionId
        # $Clone_Build_Name = $CSV_Data[$V].Clone_Build_Name
        # $Clone_Build_Id = $CSV_Data[$V].Clone_Build_Id
        $Original_Build_DefinitionId = $CSV_Data[$V].Original_Build_DefinitionId
        $Original_Build_Definition_Name = $CSV_Data[$V].Original_Build_Definition_Name
        #$Original_Build_Definition_New_Build_Id = $CSV_Data[$V].Original_Build_Definition_New_Build_Id

        try {
            $Original_Definition_URL = "$Organization_URL/$Project/_apis/build/definitions/$Original_Build_DefinitionId`?api-version=5.1"
            # This sets the $Json variable to the JSON Build Definition of the $definitionId.
            $Original_Definition_json = Invoke-RestMethod -Uri $Original_Definition_URL -Method Get -ContentType "application/json" -Headers $Headers -ErrorAction Stop

            # This will create the DATA to supply the new JSON.
            if (($Original_Definition_json.queue.pool.name | Where-Object {$_ -like "Package xxx *"})) {          
                # This will update ANY existing Propety that is in an array and matches the "Where-Object". 
                $Original_Definition_json.queue._links.self | Add-Member -NotePropertyName "href" -NotePropertyValue "" -Force 
                $Original_Definition_json.queue | Add-Member -NotePropertyName "url" -NotePropertyValue "" -Force
                $Original_Definition_json.queue.pool | Add-Member -NotePropertyName "id" -NotePropertyValue "xxxxxxxx" -Force    
                $Original_Definition_json.queue.pool | Add-Member -NotePropertyName "name" -NotePropertyValue "xxxxxxxx" -Force 
                $Original_Definition_json.queue | Add-Member -NotePropertyName "id" -NotePropertyValue "" -Force 
                $Original_Definition_json.queue | Add-Member -NotePropertyName "name" -NotePropertyValue "xxxxxxxx" -Force 
            }
            $Specific_Original_Definition_JSON_Task_Id = ($Original_Definition_json.process.phases.steps | Where-Object {$_.task.id -eq "xxxxxxxxxxxx"})
            IF ($null -ne $Specific_Original_Definition_JSON_Task_Id) {
                $Specific_Original_Definition_JSON_Task_Id.inputs | Add-Member -NotePropertyName "usePat" -NotePropertyValue "True" -Force
            }
        }
        Catch {
            $Original_Error_Message = $_.ErrorDetails.Message
            $Original_Error_Message
        }
        
        try {
            # This is the Body of the Web Request. it is all of the modified $json.
            $Original_Definition_json_PutData = $($Original_Definition_json | ConvertTo-Json -Compress -Depth 100)

            # This is the PUT URL for updating the build definition.
            $Original_Definition_PUT_URL = "$Organization_URL/$Project/_apis/build/definitions/$Original_Build_DefinitionId`?api-version=4.1"

            # This run the PUT command for Updating a Build Definition, with the newly modified JSON file.
            $Updated_Original_Definition = Invoke-RestMethod -Uri $Original_Definition_PUT_URL -Method Put -Body $Original_Definition_json_PutData -ContentType "application/json" -Headers $Headers
        }
        catch {
            $Original_Error_Message = $_.ErrorDetails.Message
            $Original_Error_Message
        }
        try {
            # This is the URL for Queueing the original Build Definition.
            $Queue_Original_Build_POST_URL = "$Organization_URL/$Project/_apis/build/builds?ignoreWarnings=$ignoreWarnings&definitionId=$Original_Build_DefinitionId&api-version=6.0"
            # This run the POST command for Creating a new Build for the original build Definition.
            $Queue_Original_Build = Invoke-RestMethod -Uri $Queue_Original_Build_POST_URL -Method POST -ContentType "application/json" -Headers $Headers -ErrorAction Stop
            # This is the new Queued Build ID for the original Build Definition.
            #$Queue_Original_Build #.id
        }
        catch {
            $Original_Error_Message = $_.ErrorDetails.Message
            $Original_Error_Message
        }

        $CSV_DATA_File_Path = "C:\Temp"
        $CSV_DATA_File = "C:\Temp\Updated_Builds.csv"
        
        # This will create the File Path if it does not exist.
        if (!(Test-Path $CSV_DATA_File_Path)) {
            #throw [System.Exception] "Cannot find $CSV_DATA_File_Path" 
            New-Item -ItemType directory -Path $CSV_DATA_File_Path -Force 
        }
        # This will create the object for the CSV.
        $Object_X = New-Object PSObject -Property @{
            "Original_Build_DefinitionId" = $Original_Build_DefinitionId
            "Original_Build_Definition_Name" = $Original_Build_Definition_Name
            "Original_Build_Definition_New_Build_Id" = $Queue_Original_Build.id
            "Original_Error_Message" = $Original_Error_Message
        }
        # This will export the CSV with the new clone Build Name, Definition ID, and Latest Cloned Build Id.
        $Object_X | Select-Object "Original_Build_DefinitionId", "Original_Build_Definition_Name", "Original_Build_Definition_New_Build_Id", "Original_Error_Message" | 
        Export-Csv -LiteralPath $CSV_DATA_File -NoTypeInformation -Encoding utf8 -NoClobber -Append -Force
    }
}
