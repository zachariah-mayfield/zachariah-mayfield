Clear-Host
$Organization_URL = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Project = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Personal_Azure_Token = "Enter_token_Here"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}
$ignoreWarnings = $true

# The below 4 lines creates the CSV Object to work with each row line and cell.
$CSV_Path = "C:\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxids.csv"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    # After the "." DefinitionId = to the column name in the CSV File.
    $Build_DefinitionId = $CSV_Data[$V].DefinitionId

    # This is a specific API Query from the API Documentation.
    $GET_URL = "$Organization_URL/$Project/_apis/build/definitions/$Build_DefinitionId`?api-version=5.1"

    # This sets the $Json variable to the JSON Build Definition of the $Build_DefinitionId.
    $json = Invoke-RestMethod -Uri $GET_URL -Method Get -ContentType "application/json" -Headers $Headers

    $CSV_DATA_File_Path = "C:\Temp"
    $CSV_DATA_File = "C:\Temp\Results.csv"
    
    # This will create the File Path if it does not exist.
    if (!(Test-Path $CSV_DATA_File_Path)) {
        #throw [System.Exception] "Cannot find $CSV_DATA_File_Path" 
        New-Item -ItemType directory -Path $CSV_DATA_File_Path -Force 
    }

    # This will create the object for the CSV.
    $Object_X = New-Object PSObject -Property @{
    "Build_DefinitionId" = $Build_DefinitionId
    "Build_Definition_Name" = $json.Name
    "Build_Definition_Agent_Pool_Name" = $json.queue.pool.name
    "Build_Definition_Repository_Name" = $json.repository.name
    "Build_Definition_Repository_ID" = $json.repository.id
    }

    $Object_X  
    $Object_X | Select-Object "Build_DefinitionId", "Build_Definition_Name", "Build_Definition_Agent_Pool_Name", "Build_Definition_Repository_Name", "Build_Definition_Repository_ID" | 
    Export-Csv -LiteralPath $CSV_DATA_File -NoTypeInformation -Encoding utf8 -NoClobber -Append -Force
}



