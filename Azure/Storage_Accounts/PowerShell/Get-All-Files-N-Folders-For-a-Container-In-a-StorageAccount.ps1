Clear-Host
$startTime = (Get-Date)
$FormatEnumerationLimit=-1

# To Comment out a Block of code
# Ctrl+K+C
# To Un-Comment a Block of code
# Ctrl+K+U

#region Check PowerShell Version
IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
#endregion Check PowerShell Version

#region Environment Variables
# Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
$client_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
$Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
$Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#endregion Environment Variables

#region 
$Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$dnsSuffix = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$grant_type="client_credentials"
$resource="https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$URI="https://login.microsoftonline.com/$($Tenant_ID)/oauth2/v2.0/token" #We are using the oauth version 2
$CONTENT_TYPE="application/x-www-form-urlencoded"#,'application/json'

$ACCESS_TOKEN_HEADERS = @{
    "Content-Type"=$CONTENT_TYPE
}

$BODY="grant_type=$($grant_type)&client_id=$($client_ID)&client_secret=$($Secret_ID)&scope=$($resource)"
$ACCESS_TOKEN = (Invoke-RestMethod -method POST -Uri $URI -Headers $ACCESS_TOKEN_HEADERS -Body $BODY).access_token

$DATE = [System.DateTime]::UtcNow.ToString("R")

$HEADERS = @{
    "x-ms-date"=$DATE 
    "x-ms-version"="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    "authorization"="Bearer $ACCESS_TOKEN"
}

# How to return all Container Names.
#$Containers_URL = "https://$($Storage_Account_Name).$($dnsSuffix)/?recursive=true&resource=account"
#$Containers_Response = (Invoke-RestMethod -Method Get -Uri $Containers_URL -Headers $HEADERS)

$Container = 'Container' 

$Container_URL = "https://$($Storage_Account_Name).$($dnsSuffix)/$($Container)?recursive=true&resource=filesystem"

$Container_Response = (Invoke-RestMethod -Method Get -Uri $Container_URL -Headers $HEADERS)

ForEach ($R in $Container_Response.paths) {
    $Service_Principal = $null
    $Service_Principal = New-Object PSObject
    $Service_Principal | add-member Noteproperty Container_Name $Container
    # Folders
    If ($R.IsDirectory -eq $true) {
        $Service_Principal | add-member Noteproperty FullName_Path ('/' + $R.Name) -Force
        $Service_Principal | add-member Noteproperty Content_Length $R.contentLength
    }
    # Files
    If ($R.IsDirectory -ne $true) {
        $Service_Principal | add-member Noteproperty FullName_Path ('/' + $R.Name) -Force
        $Service_Principal | add-member Noteproperty Content_Length $R.contentLength
    }
    $Service_Principal | Format-List
}
$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete Report for Container: $Container  Time: $(($endTime-$startTime).TotalSeconds)"
