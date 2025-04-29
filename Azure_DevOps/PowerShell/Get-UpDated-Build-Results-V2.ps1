Clear-Host
$Organization_URL = "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Personal_Azure_Token = "Enter Your PAT Here"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$ignoreWarnings = $true

# The below 4 lines creates the CSV Object to work with each row line and cell.
$CSV_Path = "C:\Temp\Updated_Builds.csv"
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


    IF ($null -ne $CSV_Data[$v]) { 
        # This is the Build Definition Id pulled from the CSV.
        $Original_Build_DefinitionId = $CSV_Data[$V].Original_Build_DefinitionId
        $Original_Build_Definition_Name = $CSV_Data[$V].Original_Build_Definition_Name
        $Original_Build_Definition_New_Build_Id = $CSV_Data[$V].Original_Build_Definition_New_Build_Id

       
        try {
            $GET_Original_Build_URL = "$Organization_URL/$Project/_apis/build/builds/$Original_Build_Definition_New_Build_Id`?api-version=6.0"
            $Original_json = Invoke-RestMethod -Uri $GET_Original_Build_URL -Method Get -ContentType "application/json" -Headers $Headers -ErrorAction Stop
            $Original_Build_Result = $Original_json.result
            IF ($Original_Build_Result -eq "failed") {
                try {
                    $Get_Original_Build_Results = "$Organization_URL/$Project/_apis/build/builds/$Original_Build_Definition_New_Build_Id/logs?api-version=6.1-preview.2"
                    $Original_Build_JSON_Results = Invoke-RestMethod -Uri $Get_Original_Build_Results -Method Get -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                    $Original_URL = $Original_Build_JSON_Results.value.url[-2]
                    $Original_URL_Log = Invoke-RestMethod -Uri $Original_URL -Method Get -ContentType "application/json" -Headers $Headers -ErrorAction Stop
                    $Original_Build_Error_Reason = ((($Original_URL_Log | Select-String -Pattern 'error') -split "`n") | Select-String -Pattern '##[error]' -SimpleMatch -AllMatches -ErrorAction Stop)[0]
                    $Original_Build_Error_Section_Starting = ((($Original_URL_Log | Select-String -Pattern 'section') -split "`n") | Select-String -Pattern '##[section]Starting:' -SimpleMatch -AllMatches -ErrorAction Stop)[-1]
                    $Original_Build_Error_Reason_Task = ((($Original_URL_Log | Select-String -Pattern 'task') -split "`n") | Select-String -Pattern ' Task         : ' -SimpleMatch -AllMatches -ErrorAction Stop)[-1]
                }
                catch {
                    $Original_Error_Message2 = $_.ErrorDetails.Message
                    IF ($null -ne $_.ErrorDetails.Message) {
                        Write-Warning $Original_Error_Message2
                    }
                }
            }
        }
        catch {
            $Original_Error_Message2 = $_.ErrorDetails.Message
            IF ($null -ne $_.ErrorDetails.Message) {
                Write-Warning $Original_Error_Message2
            }
        }
        
        $CSV_DATA_File_Path = "C:\Temp"
        $CSV_DATA_File = "C:\Temp\Updated_Builds_Results.csv"
        
        # This will create the File Path if it does not exist.
        if (!(Test-Path $CSV_DATA_File_Path)) {
            #throw [System.Exception] "Cannot find $CSV_DATA_File_Path" 
            New-Item -ItemType directory -Path $CSV_DATA_File_Path -Force 
        }
        
        # This will create the object for the CSV.
        $Object_X = New-Object PSObject -Property @{
            "Original_Build_DefinitionId" = $Original_Build_DefinitionId
            "Original_Build_Definition_Name" = $Original_Build_Definition_Name
            "Original_Build_Definition_New_Build_Id" = $Original_Build_Definition_New_Build_Id
            "Original_Build_Status" = $Original_json.status
            "Original_Build_Result" = $Original_json.result
            "Original_Error_Message" = $Original_Error_Message
            "Original_Error_Message2" = $Original_Error_Message2
            "Original_Build_Error_Reason" = $Original_Build_Error_Reason
            "Original_Build_Error_Section_Starting" = $Original_Build_Error_Section_Starting
            "Original_Build_Error_Reason_Task" = $Original_Build_Error_Reason_Task

        }
        # This will export the CSV with the new clone Build Name, Definition ID, and Latest Cloned Build Id.
        $Object_X | Select-Object "Original_Build_DefinitionId", "Original_Build_Definition_Name", "Original_Build_Definition_New_Build_Id", `
        "Original_Build_Status", "Original_Build_Result", "Original_Error_Message", "Original_Error_Message2", "Original_Build_Error_Reason", `
        "Original_Build_Error_Section_Starting", "Original_Build_Error_Reason_Task" | 
        Export-Csv -LiteralPath $CSV_DATA_File -NoTypeInformation -Encoding utf8 -NoClobber -Append -Force  
    }
}
