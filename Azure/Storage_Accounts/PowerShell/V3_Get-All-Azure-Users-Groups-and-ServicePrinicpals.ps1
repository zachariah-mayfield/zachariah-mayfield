Clear-Host
$FormatEnumerationLimit=-1
$startTime = (Get-Date)

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
Elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

#region Environment
$Environment = 'Development' 
$Storage_Account_Name = 'xxxxxxxxxxxxx' 

IF ($Environment -eq 'Development') {
#region IDs
    # Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
    $Client_ID = 'xxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    # $Tenant_Name = "xxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
    $Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxx'
#endregion IDs
    # $Subscription_Name = 'xxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=Azure_XXXX_XXXX_DEV"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Microsoft.PowerShell.Security\Certificate::LocalMachine\My' -Recurse | Where-Object {$_.Subject -match "CN=Azure_XXXX_XXXX_Dev"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
ElseIF ($Environment -eq 'Production') {
#region IDs
    # Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
    $Client_ID = 'xxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    # $Tenant_Name = "xxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
    $Secret_ID = 'xxxxxxxxxxxxxxx'
#endregion IDs
    # $Subscription_Name = 'xxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'ocio-dav-prd'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'XXXX_XXXX_PROD'
    $Application_ID = 'xxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=Azure_XXXX_XXXX_Prod"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Microsoft.PowerShell.Security\Certificate::LocalMachine\My' -Recurse | Where-Object {$_.Subject -match "CN=Azure_XXXX_XXXX_Prod"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
Else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}

$Certificate_Auth = $true

IF ($Certificate_Auth -eq $true) {
    # This connects to Azure with the supplied parameters.
    Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Application_ID -Tenant $Tenant_ID -CertificateThumbprint $Certificate_Thumbprint | Out-Null
}
Else {
    $Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
    $UserName = "$($env:USERNAME)@XXX.com"
    $EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
    Connect-AzAccount -Credential $Credential -Subscription $Subscription_ID -Tenant $Tenant_ID | Out-Null
}

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

#endregion Environment

# Ensures you do not inherit an AzContext in your runbook
#Disable-AzContextAutosave -Scope Process

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
    $ALL_AZ_AD_Object =  $null
    $AZ_AD_Object_URI = "https://graph.microsoft.com/v1.0/$($AZ_AD_Object)"

    [Array]$All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $AZ_AD_Object_URI -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
    
    IF ($All_AZ_AD_Object_Response.Value.Count -eq 0) { 
        Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AZ_AD_$($AZ_AD_Object) found - Houston we have a problem. . ." 
        Break 
    }
    
    $1st_AZ_AD_Object_Set = $All_AZ_AD_Object_Response.Value
    
    $XXXXX = $All_AZ_AD_Object_Response.'@XXXXX.XXXXX'
    
    #$count = 1
    
    While ($Null -ne $XXXXX <#-and $count -le 2#>) {
        $All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $XXXXX -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
        $ALL_AZ_AD_Object += $All_AZ_AD_Object_Response.Value
        $XXXXX = $All_AZ_AD_Object_Response.'@XXXXX.XXXXX'
        #$count ++
    }
    $ALL_AZ_AD_Object = ($1st_AZ_AD_Object_Set + $ALL_AZ_AD_Object)
    
    $ALL_AZ_AD_Object_csv_Path = "C:\Temp\ALL_AZ_AD_$($AZ_AD_Object)_List.csv"
    
    If (Test-Path -Path $ALL_AZ_AD_Object_csv_Path) {
        Remove-Item -Path $ALL_AZ_AD_Object_csv_Path -Force -Verbose
    }

    $ALL_AZ_AD_Object | Select-Object displayName, Id, userPrincipalName | Export-Csv $ALL_AZ_AD_Object_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force
    
    #$ALL_AZ_AD_Object | Select-Object displayName, Id, userPrincipalName

#endregion AZ AD Objects

    # Set AZ Storeage Context
    $Source_File = $ALL_AZ_AD_Object_csv_Path
    $Container_Name = "az-ad-objects" 
    $Folder_Path = "az-ad-$($AZ_AD_Object)/"
    $Destination_Path = $Folder_Path + (Get-Item $Source_File).Name
    # Upload and Overwrite File to Azure Data Lake
    #New-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container_Name -Path $Destination_Path -Source $Source_File -Force -Verbose
    Set-AZStorageBlobContent -Context $Azure_Storage_Context -File $Source_File -Container $Container_Name -Blob $Destination_Path -Force -verbose -ErrorAction Stop
}

$endTime = (Get-Date)
Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "Time to Complete - Time: $(($endTime-$startTime).TotalSeconds)"
