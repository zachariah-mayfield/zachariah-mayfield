Clear-Host

#region Notes

#endregion Notes

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
}


# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$client_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXX'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

$Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$dnsSuffix = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$Container = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

$URI="https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #using the oauth version 2
$CONTENT_TYPE="application/x-www-form-urlencoded"

$ACCESS_TOKEN_HEADERS = @{
    "Content-Type"=$CONTENT_TYPE
}

$grant_type="client_credentials"
$resource="https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$BODY="grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($resource)"
$ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $BODY).access_token

$DATE = [System.DateTime]::UtcNow.ToString("R")

$HEADERS = @{
    "x-ms-date"=$DATE 
    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization"="Bearer $ACCESS_TOKEN"
}

$URL = "https://$($Account_Name).$($dnsSuffix)/$($Container)?recursive=true&resource=filesystem"

$Response = (Invoke-RestMethod -Method Get -Uri $URL -Headers $HEADERS)

$Response.paths

ForEach ($R in $Response.paths) {
    If ($R.IsDirectory -eq $true) {
        $R.Name
    }
}

