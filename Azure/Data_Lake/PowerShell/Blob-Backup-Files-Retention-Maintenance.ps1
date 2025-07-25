Clear-Host
$FormatEnumerationLimit=-1

#region Azure Auth Variables
# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$client_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#endregion Azure Auth Variables

#region API Header Auth 
$dnsSuffix = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$grant_type = "client_credentials"
$API_Resource="https://storage.azure.com/.default"
$URI = "https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #We are using the oauth version 2
$CONTENT_TYPE = "application/x-www-form-urlencoded"#,'application/json'
$ACCESS_TOKEN_HEADERS = @{"Content-Type"=$CONTENT_TYPE}
$BODY = "grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($API_Resource)"
$ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $BODY).access_token 
$DATE = [System.DateTime]::UtcNow.ToString("R")
$HEADERS = @{
    "x-ms-date" = $DATE 
    "x-ms-version" = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization" = "Bearer $ACCESS_TOKEN"
}
#endregion API Header Auth 

$Account_Names = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

ForEach ($Account_Name in $Account_Names) {

    $Container = 'xxxxxx' 

    $Container_URL = "https://$($Account_Name).$($dnsSuffix)/$($Container)?recursive=true&resource=filesystem"
    $Container_Response = (Invoke-RestMethod -Method Get -Uri $Container_URL -Headers $HEADERS) 

    ForEach ($C_Path in $Container_Response.paths) {
        # Get Day of the week
        If ($C_Path.name -match "backup.tar.gz") {
            $Blob_file_name = $null
            $Blob_file_name = ($C_Path.name.Split('_')[0])
            $Blob_file_name = $Blob_file_name.Substring(0,$Blob_file_name.Length -4).Insert('4','/').Insert('7','/')
            $DATE = [DateTime]$Blob_file_name
            $DayOfTheWeek = $DATE.DayOfWeek
            $SevenDaysOld = ((Get-Date).AddDays(-7))
        }
        If ($DayOfTheWeek -notmatch "Sunday" -and $SevenDaysOld -gt $DATE) {
            Write-Host -ForegroundColor Cyan "Deleting Blob: $($C_Path.name)"
            $Blob_Delete_Status = (Invoke-WebRequest -Method Delete -Uri "https://$($Account_Name).$($dnsSuffix)/$($Container)/$($C_Path.Name)" -Headers $HEADERS)
            If ($Blob_Delete_Status.StatusCode -eq 200) {
                Write-Host -ForegroundColor Green "Successfully Deleted Blob: $($C_Path.name)"
            }
        }
        Else {
            Write-Host -ForegroundColor Yellow "Keeping Blob: $($C_Path.name)"
        }
    }
}
