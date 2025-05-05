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
$Storage_Account_Name = 'xxxxxxxxx' 

IF ($Environment -eq 'Development') {
#region IDs
    # Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
    $Client_ID = 'xxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    # $Tenant_Name = "CDC"
    $Tenant_ID = 'xxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
    $Secret_ID = 'xxxxxxxxxxxxxxxx'
#endregion IDs
    # $Subscription_Name = 'xxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=Azure_xxxxx_xxxxx_DEV"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Microsoft.PowerShell.Security\Certificate::LocalMachine\My' -Recurse | Where-Object {$_.Subject -match "CN=Azure_xxxxx_xxxxx_Dev_V3"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
ElseIF ($Environment -eq 'Production') {
#region IDs
    # Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
    $Client_ID = 'xxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    # $Tenant_Name = "CDC"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
    $Secret_ID = 'xxxxxxxxxxxxxxx'
#endregion IDs
    # $Subscription_Name = 'xxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=Azure_xxxxxxxxxxx"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'Microsoft.PowerShell.Security\Certificate::LocalMachine\My' -Recurse | Where-Object {$_.Subject -match "CN=Azure_xxxxxxxxxxxx"}).Thumbprint
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
    $UserName = "$($env:USERNAME)@xxxxxxxxxx.com"
    $EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
    Connect-AzAccount -Credential $Credential -Subscription $Subscription_ID -Tenant $Tenant_ID | Out-Null
}

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

#endregion Environment

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
$AZ_AD_Objects = ('groups')

ForEach ($AZ_AD_Object in $AZ_AD_Objects) {
    $ALL_AZ_AD_Object =  $null
    $AZ_AD_Object_URI = "https://graph.microsoft.com/v1.0/$($AZ_AD_Object)"

    [Array]$All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $AZ_AD_Object_URI -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
    
    IF ($All_AZ_AD_Object_Response.Value.Count -eq 0) { 
        Write-Host -ForegroundColor Cyan -BackgroundColor Yellow "No AZ_AD_$($AZ_AD_Object) found - Houston we have a problem. . ." 
        Break 
    }
    
    $1st_AZ_AD_Object_Set = $All_AZ_AD_Object_Response.Value
    
    $xxxxxLink = $All_AZ_AD_Object_Response.'@xxxxxxxxxx.xxxxxxxxxxxxk'
    
    #$count = 1
    
    While ($Null -ne $xxxxxLink <#-and $count -le 40#>) {
        $All_AZ_AD_Object_Response = Invoke-WebRequest -Method GET -Uri $xxxxxLink -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
        $ALL_AZ_AD_Object += $All_AZ_AD_Object_Response.Value
        $xxxxxLink = $All_AZ_AD_Object_Response.'@oxxxxxx.xxxxxxxxxxxxxxxk'
        #$count ++
    }
    $ALL_AZ_AD_Object = ($1st_AZ_AD_Object_Set + $ALL_AZ_AD_Object)
    
    $ALL_AZ_AD_Object_csv_Path = "C:\Temp\ALL_AZ_AD_GP-U-xxxxx_$($AZ_AD_Object)_List.csv"
    
    If (Test-Path -Path $ALL_AZ_AD_Object_csv_Path) {
        Remove-Item -Path $ALL_AZ_AD_Object_csv_Path -Force -Verbose
    }

    $GP_U_xxxxx_Groups = $ALL_AZ_AD_Object | Select-Object displayName, ID | Where-Object {$_.displayName -like "gp-u-xxxxxxxxxxxxx*"}

    ForEach ($AZ_AD_Group in $GP_U_xxxx_Groups) {
        $AZ_AD_Group_Owners_URI = "https://graph.microsoft.com/v1.0/groups/$($AZ_AD_Group.ID)/owners"
        $AZ_AD_Group_Owners_Response = Invoke-WebRequest -Method GET -Uri $AZ_AD_Group_Owners_URI -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json
        $AZ_AD_Group_Members_URI = "https://graph.microsoft.com/v1.0/groups/$($AZ_AD_Group.ID)/members"
        $AZ_AD_Group_Members_Response = Invoke-WebRequest -Method GET -Uri $AZ_AD_Group_Members_URI -ContentType "application/json" -Headers $UH_HEADERS -UseBasicParsing | ConvertFrom-Json

        $E_AZ_AD_Group_OBJ = @{
            'AZ_AD_Group' = (($AZ_AD_Group.displayName | Out-String).Trim())
            'AZ_AD_Group_Owner' = (($AZ_AD_Group_Owners_Response.value.DisplayName | Out-String).Trim())
            'AZ_AD_Group_Owner_IDs' = (($AZ_AD_Group_Owners_Response.value.id | Out-String).Trim())
            'AZ_AD_Group_Members' = (($AZ_AD_Group_Members_Response.value.DisplayName | Out-String).Trim())
            'AZ_AD_Group_Member_IDs'= (($AZ_AD_Group_Members_Response.value.id | Out-String).Trim())
        }
        $MyPSObject = [pscustomobject]$E_AZ_AD_Group_OBJ
        $MyPSObject | Format-List
        $MyPSObject | Select-Object -Property 'AZ_AD_Group', 'AZ_AD_Group_Owner', 'AZ_AD_Group_Owner_IDs', 'AZ_AD_Group_Members', 'AZ_AD_Group_Member_IDs' | Export-Csv $ALL_AZ_AD_Object_csv_Path -NoClobber -Encoding 'UTF8' -NoTypeInformation -Append -Force
    }

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
