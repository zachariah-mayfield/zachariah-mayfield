Clear-Host
$FormatEnumerationLimit=-1
$startTime = (Get-Date)

#region IDs
# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$Client_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#endregion IDs

#region UH_Headers for access token
$grant_type="client_credentials"
$URI="https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #using the oauth version 2
$UH_resource="https://graph.microsoft.com/.default"
$UH_BODY="grant_type=$($grant_type)&client_id=$($Client_ID)&client_secret=$($Secret_ID)&scope=$($UH_resource)"
$UH_ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $UH_BODY).access_token
$UH_DATE = [System.DateTime]::UtcNow.ToString("R")
$UH_HEADERS = @{
    "x-ms-date"=$UH_DATE 
    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization"="Bearer $UH_ACCESS_TOKEN"
}
#endregion UH_Headers for access token

#region AZ AD Users
$AZ_AD_Users_URI = "https://graph.microsoft.com/v1.0/users"

[Array]$AzAD_Users = Invoke-WebRequest -Method GET -Uri $AZ_AD_Users_URI -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json

IF ($AzAD_Users.Value.Count -eq 0) { 
    Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AzAD_Users found - Houston we have a problem. . ." 
    Break 
}

$1st_AZ_AD_Users_Set = $AzAD_Users.Value

$X_AD_Group = $AzAD_Users.'@O.X_AD_Group'

$count = 1

While ($Null -ne $X_AD_Group -and $count -le 2) {
    $AzAD_Users = Invoke-WebRequest -Method GET -Uri $X_AD_Group -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json
    $ALL_AZ_AD_Users += $AzAD_Users.Value
    $X_AD_Group = $AzAD_Users.'@o.X_AD_Group'
    $count ++
}
$ALL_AZ_AD_Users = ($1st_AZ_AD_Users_Set + $ALL_AZ_AD_Users)

$ALL_AZ_AD_Users_csv_Path = "C:\Temp\List.csv"

$ALL_AZ_AD_Users | Select-Object displayName, Id, userPrincipalName | Export-Csv $ALL_AZ_AD_Users_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force

Write-Host -ForegroundColor Cyan "Azure AD Users count:  $($ALL_AZ_AD_Users.Count)"
#endregion AZ AD Users

#region AZ AD Groups
$AZ_AD_Groups_URI = "https://graph.microsoft.com/v1.0/groups"

[Array]$AzAD_Groups = Invoke-WebRequest -Method GET -Uri $AZ_AD_Groups_URI -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json

IF ($AzAD_Groups.Value.Count -eq 0) { 
    Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AzAD_Groups found - Houston we have a problem. . ." 
    Break 
}

$1st_AZ_AD_Groups_Set = $AzAD_Groups.Value

$X_AD_Group = $AzAD_Groups.'@O.X_AD_Group'

$count = 1

While ($Null -ne $X_AD_Group -and $count -le 2) {
    $AzAD_Groups = Invoke-WebRequest -Method GET -Uri $X_AD_Group -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json
    $ALL_AZ_AD_Groups += $AzAD_Groups.Value
    $X_AD_Group = $AzAD_Groups.'@o.X_AD_Group'
    $count ++
}
$ALL_AZ_AD_Groups = ($1st_AZ_AD_Groups_Set + $ALL_AZ_AD_Groups)

$ALL_AZ_AD_Groups_csv_Path = "C:\Temp\List.csv"

$ALL_AZ_AD_Groups | Select-Object displayName, Id | Export-Csv $ALL_AZ_AD_Groups_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force

Write-Host -ForegroundColor Cyan "Azure AD Groups count:  $($ALL_AZ_AD_Groups.Count)"
#endregion AZ AD Groups

#region AZ AD Service Principals
$AZ_AD_ServicePrincipals_URI = "https://graph.microsoft.com/v1.0/ServicePrincipals"

[Array]$AzAD_ServicePrincipals = Invoke-WebRequest -Method GET -Uri $AZ_AD_ServicePrincipals_URI -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json

IF ($AzAD_ServicePrincipals.Value.Count -eq 0) { 
    Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AzAD_ServicePrincipals found - Houston we have a problem. . ." 
    Break 
}

$1st_AZ_AD_ServicePrincipals_Set = $AzAD_ServicePrincipals.Value

$X_AD_Group = $AzAD_ServicePrincipals.'@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

$count = 1

While ($Null -ne $X_AD_Group -and $count -le 2) {
    $AzAD_ServicePrincipals = Invoke-WebRequest -Method GET -Uri $X_AD_Group -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json
    $ALL_AZ_AD_ServicePrincipals += $AzAD_ServicePrincipals.Value
    $X_AD_Group = $AzAD_ServicePrincipals.'@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $count ++
}
$ALL_AZ_AD_ServicePrincipals = ($1st_AZ_AD_ServicePrincipals_Set + $ALL_AZ_AD_ServicePrincipals)

$ALL_AZ_AD_ServicePrincipals_csv_Path = "C:\Temp\List.csv"

$ALL_AZ_AD_ServicePrincipals | Select-Object displayName, Id | Export-Csv $ALL_AZ_AD_ServicePrincipals_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force

Write-Host -ForegroundColor Cyan "Azure AD ServicePrincipals count:  $($ALL_AZ_AD_ServicePrincipals.Count)"
#endregion AZ AD Service Principals

#region Upload Content

#region Environment
$Azure_Environment = 'Development'

If ($Azure_Environment -eq 'Development') {
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    $Tenant_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    $Subscription_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    $Storage_Account_Name = 'dev_account'
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' 
    $Blob_Path = '/Test/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/'
    $Application_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=DEV"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=Azure__DEV"}).Thumbprint
}
Elseif ($Azure_Environment -eq 'Production') {
    $Tenant_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    $Subscription_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    $Storage_Account_Name = 'dev_account' 
    $Container_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Blob_Path = '/Test/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/'
    $Application_Id = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=Prod"
    $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=Azure__Prod"}).Thumbprint
}
Else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}
#endregion Environment
# This connects to Azure with the supplied parameters.
Connect-AzAccount -Subscription $Subscription_Id -ApplicationId $Application_Id -Tenant $Tenant_Id -CertificateThumbprint $CertificateThumbprint | Out-Null

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

$Source = 'C:\Temp\Az_AD_ObjectIDs'

$AZ_AD_Files = (Get-childitem -Path $Source | Where-Object {$_.Name -like "*.csv"})

ForEach ($AZ_AD_File in $AZ_AD_Files) {
    Try {
        $Blob = ($Blob_Path + $AZ_AD_File.Name)
        $File = ($AZ_AD_File.FullName)
        Set-AZStorageBlobContent -Context $Azure_Storage_Context -File $File -Blob $Blob -Container $Container_Name -Force -verbose -ErrorAction Stop
        Write-Output "$(Get-Date)  -  Removing file: $($File)" | Out-File -FilePath "C:\Temp\Log.txt" -NoClobber -Append -Force
        Remove-Item -Path $File -Force -verbose -ErrorAction Stop
    }
    Catch {
        IF ($_.Exception) {
            Write-Host -ForegroundColor Yellow $_.Exception
        }
        Exit-PSHostProcess
    }
}
#endregion Upload Content

$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete - Time: $(($endTime-$startTime).TotalSeconds)"
