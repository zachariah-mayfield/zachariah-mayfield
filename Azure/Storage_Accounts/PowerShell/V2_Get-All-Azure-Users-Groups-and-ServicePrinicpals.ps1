Clear-Host
$startTime = (Get-Date)
$FormatEnumerationLimit=-1
#region IDs
# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$Client_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
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

$URI = "https://graph.microsoft.com/v1.0/users"

[Array]$AzAD_Users = Invoke-WebRequest -Method GET -Uri $URI -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json

IF ($AzAD_Users.Value.Count -eq 0) { 
    Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AzAD_Users found - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    Break 
}

$1st_AZ_AD_Users_Set = ForEach ($AzAD_User in $AzAD_Users.Value) {
    $Hash_Obj = New-Object PSObject
    $Hash_Obj | add-member Noteproperty displayName $AzAD_User.displayName -Force
    $Hash_Obj | add-member Noteproperty id $AzAD_User.id
    $Hash_Obj | add-member Noteproperty givenName $AzAD_User.givenName
    $Hash_Obj | add-member Noteproperty surname $AzAD_User.surname
    $Hash_Obj | add-member Noteproperty userPrincipalName $AzAD_User.userPrincipalName
    $Hash_Obj | add-member Noteproperty mail $AzAD_User.mail
    $Hash_Obj
}

$X_AD_Group = $AzAD_Users.'@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

While ($Null -ne $X_AD_Group) {
    $AzAD_Users = Invoke-WebRequest -Method GET -Uri $X_AD_Group -ContentType "application/json" -Headers $UH_HEADERS | ConvertFrom-Json
#region wanted data
    ForEach ($AzAD_User in $AzAD_Users.Value) {
        $Hash_Obj = New-Object PSObject
        $Hash_Obj | add-member Noteproperty displayName $AzAD_User.displayName -Force
        $Hash_Obj | add-member Noteproperty id $AzAD_User.id
        $Hash_Obj | add-member Noteproperty givenName $AzAD_User.givenName
        $Hash_Obj | add-member Noteproperty surname $AzAD_User.surname
        $Hash_Obj | add-member Noteproperty userPrincipalName $AzAD_User.userPrincipalName
        $Hash_Obj | add-member Noteproperty mail $AzAD_User.mail
    }
    $Hash_Obj
#endregion wanted data
    $X_AD_Group = $AzAD_Users.'@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp'
}
$ALL_AZ_AD_Users = ($1st_AZ_AD_Users_Set + $Hash_Obj)
$ALL_AZ_AD_Users

Write-Host -ForegroundColor Cyan "Azure AD Users count:  $($ALL_AZ_AD_Users.Count)"

$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete Report - Time: $(($endTime-$startTime).TotalSeconds)"
