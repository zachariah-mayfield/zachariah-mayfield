Clear-Host
$Organization_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Personal_Azure_Token = "Enter Your PAT Here"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$ignoreWarnings = $true

# The below 4 lines creates the CSV Object to work with each row line and cell.
$CSV_Path = "C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.csv"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    $New_Clone = $null
    $New_Clone_Build_Queue = $null
    $Latest_Cloned_Build = $null
    $Clone_Error_Message = $null
    $definitionId = $null
    $definitionName = $null
    $Original_Queued_New_Build = $null
    $Original_Error_Message = $null

    IF ($null -ne $CSV_Data[$v]) { 
        # This is the Original Build Definition Id and Name pulled from the CSV.
        $definitionId = $CSV_Data[$V].DefinitionId
        $definitionName = $CSV_Data[$V].DefinitionName

        TRY {
            # This is the URL for Queueing the original Build Definition.
            $Post_Queue_Original_Build_URL = "$Organization_URL/$Project/_apis/build/builds?ignoreWarnings=$ignoreWarnings&definitionId=$definitionId&api-version=6.0"
            # This run the POST command for Creating a new Build for the original build Definition.
            $Post_Queue_Original_Build = Invoke-RestMethod -Uri $Post_Queue_Original_Build_URL -Method POST -ContentType "application/json" -Headers $Headers -ErrorAction Stop
            # This is the new Queued Build ID for the original Build Definition.
            $Original_Queued_New_Build = $Post_Queue_Original_Build.id
            try {
                # This is the URL that pulls the JSON to clone from.
                $GET_URL = "$Organization_URL/$Project/_apis/build/definitions/$definitionId`?api-version=5.1"
                # This sets the $Json variable to the JSON Build Definition of the $definitionId.
                $json = Invoke-RestMethod -Uri $GET_URL -Method Get -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                # New Clone $json Name
                $json.Name = $json.Name + "_Clone_"
                # This will create the DATA to supply the new JSON.
                if (($json.queue.pool.name | Where-Object {$_ -like "Package xx *"})) {          
                    # This will update ANY existing Propety that is in an array and matches the "Where-Object". 
                    $json.queue._links.self | Add-Member -NotePropertyName "href" -NotePropertyValue "" -Force 
                    $json.queue | Add-Member -NotePropertyName "url" -NotePropertyValue "" -Force
                    $json.queue.pool | Add-Member -NotePropertyName "id" -NotePropertyValue "1234" -Force    
                    $json.queue.pool | Add-Member -NotePropertyName "name" -NotePropertyValue "xxx.xxx.xx" -Force 
                    $json.queue | Add-Member -NotePropertyName "id" -NotePropertyValue "" -Force 
                    $json.queue | Add-Member -NotePropertyName "name" -NotePropertyValue "xxx.xxx.xx" -Force 
                }

                $Specific_JSON_Task_Id = ($json.process.phases.steps | Where-Object {$_.task.id -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"})
                IF ($null -ne $Specific_JSON_Task_Id){
                    $Specific_JSON_Task_Id.inputs | Add-Member -NotePropertyName "usePat" -NotePropertyValue "True" -Force
                }

                # This is the URL that runs the POST command for Creating a new Cloned Build Definition, with the newly modified JSON file.
                $POST_URL = "$Organization_URL/$Project/_apis/build/definitions?definitionToCloneId=$definitionId&api-version=6.1-preview.7"
                # This is the Body of the Web Request. it is all of the modified $json.
                $POST_Data = $($json | ConvertTo-Json -Compress -Depth 100)
                try {
                    # This run the POST command for Creating a new Build Definition, with the newly modified JSON file.
                   $New_Clone = Invoke-RestMethod -Uri $POST_URL -Method POST -Body $POST_Data -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                   # This will output the new build cloned build definition Id.
                   $Clone_Build_DefinitionId = $New_Clone.id
                    try {
                        # Creating the POST URL to start the Build Queue 
                        $New_Clone_Build_Queue_URL = "$Organization_URL/$Project/_apis/build/builds?ignoreWarnings=$ignoreWarnings&definitionId=$Clone_Build_DefinitionId&api-version=6.1-preview.6" 
                        # Start the Queue of the new build.
                        $New_Clone_Build_Queue = Invoke-RestMethod -Uri $New_Clone_Build_Queue_URL -Method POST -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                        $Latest_Cloned_Build_Id = $New_Clone_Build_Queue.id
                        try {
                            # Creating the POST URL to start the Build Queue 
                            $New_Clone_Build_Queue_URL = "$Organization_URL/$Project/_apis/build/builds?ignoreWarnings=$ignoreWarnings&definitionId=$Clone_Build_DefinitionId&api-version=6.1-preview.6" 
                            # Start the Queue of the new build.
                            $New_Clone_Build_Queue = Invoke-RestMethod -Uri $New_Clone_Build_Queue_URL -Method POST -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                            $Latest_Cloned_Build_Id = $New_Clone_Build_Queue.id
                            try {
                                # This is the URL that will use to get Cloned Build ID.
                                $GET_latest_Cloned_Build_URL = "$Organization_URL/$Project/_apis/build/builds/$Latest_Cloned_Build_Id`?api-version=6.0"
                                # Latest Cloned Build.
                                $Latest_Cloned_Build = Invoke-RestMethod -Uri $GET_latest_Cloned_Build_URL -Method GET -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                            }
                            catch {
                                $Clone_Error_Message = $_.ErrorDetails.Message
                                Write-Warning $Clone_Error_Message
                            }
                        }
                        catch {
                            $Clone_Error_Message = $_.ErrorDetails.Message
                            Write-Warning $Clone_Error_Message
                        }
                    }
                    catch {
                        $Clone_Error_Message = $_.ErrorDetails.Message
                        Write-Warning $Clone_Error_Message
                    }
                }
               catch {
                   $Clone_Error_Message = $_.ErrorDetails.Message
                   Write-Warning $Clone_Error_Message
               }
            }
            Catch {
                $Clone_Error_Message = $_.ErrorDetails.Message
                Write-Warning $Clone_Error_Message
            } 
        }
        Catch {
            $Original_Error_Message = $_.ErrorDetails.Message
            Write-Warning $Original_Error_Message
        }

        $CSV_DATA_File_Path = "C:\Temp"
        $CSV_DATA_File = "C:\Temp\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.csv"
        
        # This will create the File Path if it does not exist.
        if (!(Test-Path $CSV_DATA_File_Path)) {
            #throw [System.Exception] "Cannot find $CSV_DATA_File_Path" 
            New-Item -ItemType directory -Path $CSV_DATA_File_Path -Force 
        }
        
        # This will create the object for the CSV.
        $Object_X = New-Object PSObject -Property @{
            "Clone_Build_Name" = $New_Clone.name
            "Clone_Build_DefinitionId" = $New_Clone_Build_Queue.definition.id
            "Clone_Build_Id" = $Latest_Cloned_Build.Id
            "Clone_Error_Message" = $Clone_Error_Message
            "Original_Build_DefinitionId" = $definitionId
            "Original_Build_Definition_Name" = $definitionName
            "Original_Build_Definition_New_Build_Id" = $Original_Queued_New_Build
            "Original_Error_Message" = $Original_Error_Message
        }
        
        # This will export the CSV with the new clone Build Name, Definition ID, and Latest Cloned Build Id.
        $Object_X | Select-Object "Original_Build_DefinitionId", "Original_Build_Definition_Name", "Original_Build_Definition_New_Build_Id", "Original_Error_Message", "Clone_Build_DefinitionId", `
            "Clone_Build_Name", "Clone_Build_Id", "Clone_Error_Message" | 
        Export-Csv -LiteralPath $CSV_DATA_File -NoTypeInformation -Encoding utf8 -NoClobber -Append -Force
    }
}
