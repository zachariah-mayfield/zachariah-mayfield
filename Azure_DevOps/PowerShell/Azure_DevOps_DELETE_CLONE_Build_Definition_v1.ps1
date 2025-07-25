Clear-Host
$Organization_URL = "https://xxxxxxxxx"
$Project = "xxxxxxxxxxxxxx"
$Personal_Azure_Token = "xxxxxxxxxxxxxx"
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Personal_Azure_Token)"))
$Headers = @{authorization = "Basic $Token"}

# The below 4 lines creates the CSV Object to work with each row line and cell.
$CSV_Path = "C:\xxxxxxxxx.xlsx"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    IF ($null -ne $CSV_Data[$v]) { 
        # This is the Build Definition Id pulled from the CSV.
        $Clone_Build_DefinitionId = $CSV_Data[$V].Clone_Build_DefinitionId

        try {
            $DELETE_Cloned_Build_URL = "$Organization_URL/$Project/_apis/build/definitions/$Clone_Build_DefinitionId ?api-version=4.1"
            $DELETE_json = Invoke-RestMethod -Uri $DELETE_Cloned_Build_URL -Method DELETE -ContentType "application/json" -Headers $Headers -ErrorAction Stop
            $DELETE_json
        }
        catch {
            $Delete_Error_Message = $_.ErrorDetails.Message
            Write-Warning $Delete_Error_Message
        }
    }
}
