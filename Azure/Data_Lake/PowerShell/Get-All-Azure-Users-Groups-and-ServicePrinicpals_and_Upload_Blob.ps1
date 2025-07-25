Clear-Host
$FormatEnumerationLimit=-1
$startTime = (Get-Date)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

#region IDs
# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$Client_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#endregion IDs

#region UH_Headers for access token
$CONTENT_TYPE="application/x-www-form-urlencoded"#,'application/json'
$ACCESS_TOKEN_HEADERS = @{
    "Content-Type"=$CONTENT_TYPE
}
$grant_type="client_credentials"
$URI="https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #We are using the oauth version 2
$UH_resource="https://graph.microsoft.com/.default"
$UH_BODY="grant_type=$($grant_type)&client_id=$($Client_ID)&client_secret=$($Secret_ID)&scope=$($UH_resource)"
$UH_ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $UH_BODY -UseBasicParsing).access_token
$UH_DATE = [System.DateTime]::UtcNow.ToString("R")
$UH_HEADERS = @{
    "x-ms-date"=$UH_DATE 
    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization"="Bearer $UH_ACCESS_TOKEN"
}
#endregion UH_Headers for access token
#region AZ AD Objects
$AZ_AD_Objects = ('users', 'groups', 'servicePrincipals')

ForEach ($AZ_AD_Object in $AZ_AD_Objects) {

    $AZ_AD_Object_URI = "https://graph.microsoft.com/v1.0/$($AZ_AD_Object)"

    [Array]$All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $AZ_AD_Object_URI -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
    

    IF ($All_AZ_AD_Object_Response.Value.Count -eq 0) { 
        Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AZ_AD_$($AZ_AD_Object) found . . ." 
        Break 
    }
    
    $1st_AZ_AD_Object_Set = $All_AZ_AD_Object_Response.Value
    
    $XXXXXX = $All_AZ_AD_Object_Response.'@XXXXXX.XXXXXX'
    
    $count = 1
    
    While ($Null -ne $XXXXXX -and $count -le 2) {
        $All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $XXXXXX -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
        $ALL_AZ_AD_Object += $All_AZ_AD_Object_Response.Value
        $XXXXXX = $All_AZ_AD_Object_Response.'@XXXXXX.XXXXXX'
        $count ++
    }
    $ALL_AZ_AD_Object = ($1st_AZ_AD_Object_Set + $ALL_AZ_AD_Object)
    
    $ALL_AZ_AD_Object_csv_Path = "ALL_AZ_AD_$($AZ_AD_Object)_List.csv"
    
    $ALL_AZ_AD_Object | Select-Object displayName, Id, userPrincipalName | Export-Csv $ALL_AZ_AD_Object_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force
    
    $ALL_AZ_AD_Object | Select-Object displayName, Id, userPrincipalName

#endregion AZ AD Objects

    # Set AZ Storeage Context
    $AzStorageContext = New-AzStorageContext -StorageAccountName 'zzzzzzzzzzz' -StorageAccountKey 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
    $Source_File = ".\$($ALL_AZ_AD_Object_csv_Path)"
    $Container_Name = "az-ad-objects" 
    $Folder_Path = "az-ad-$($AZ_AD_Object)/"
    $Destination_Path = $Folder_Path + (Get-Item $Source_File).Name
    # Upload and Overwrite File to Azure Data Lake
    New-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container_Name -Path $Destination_Path -Source $Source_File -Force -Verbose
}

$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete - Time: $(($endTime-$startTime).TotalSeconds)"

