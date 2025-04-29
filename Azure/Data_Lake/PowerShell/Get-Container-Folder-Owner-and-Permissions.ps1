Clear-Host

# Step 1. Create Certificate
# New-SelfSignedCertificate -Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -CertStoreLocation "Cert:\LocalMachine" -KeyExportPolicy 'Exportable' -KeySpec 'Signature' `
# -KeyDescription 'Certificate for Authenicating to Azure Company Dev' -KeyAlgorithm 'RSA' -KeyLength 2048 -NotAfter (Get-Date).AddYears(5) 

IF ($PSVersionTable.PSVersion.Major -lt '7') {
	Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
    # Install latest version of powershell:
    # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

$Environment = 'Development' 
$Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' 
$Container = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$Folder_Prefix = 'work'

IF ($Environment -eq 'Development') {
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=Azure_Company_INFRA_DEV"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
ElseIF ($Environment -eq 'Production') {
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # This pulls the (Certificate Thumbprint) from the Certificate path 'cert:\LocalMachine\my\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Certificate_Thumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\my\' | Where-Object {$_.Subject -match "CN=Azure_Company_INFRA_Prod"}).Thumbprint
    #$Storage_Account_Name
    #$Container
}
Else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}

$Certificate_Auth = $false

IF ($Certificate_Auth -eq $true) {
    # This connects to Azure with the supplied parameters.
    Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Application_ID -Tenant $Tenant_ID -CertificateThumbprint $Certificate_Thumbprint | Out-Null
}
Else {
    $Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
    $UserName = "qbx3@cdc.gov"
    $EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
    Connect-AzAccount -Credential $Credential -Subscription $Subscription_ID -Tenant $Tenant_ID | Out-Null
}

# This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
$Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

$Entity_Ids = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container -Path $Folder_Prefix).acl | Where-Object {$null -ne $_.EntityId -and $_.DefaultScope -eq $false}

$Owner = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container -Path $Folder_Prefix)

IF ($Owner.Owner -ne '$superuser') {
    try {
        $Container_Owner = (Get-AzADUser -ObjectId $Owner.Owner -ErrorAction 'Stop').DisplayName
    }
    catch { 
        IF ($_.Exception) {
            try {
                $Container_Owner = (Get-AzADServicePrincipal -ObjectId $Owner.Owner -ErrorAction 'Stop').DisplayName
            }
            catch {
                IF ($_.Exception) {
                    try {
                        $Container_Owner = (Get-AzADUser -ObjectId $Owner.Owner -ErrorAction 'Stop').DisplayName
                    }
                    catch {
                        IF ($_.Exception) {
                            Write-Host -ForegroundColor Yellow $_.Exception
                        }
                    }
                }
            }       
        }
    }
}

Write-Host -ForegroundColor Cyan "The owner of the Container is: $($Container_Owner)"

ForEach ($Entity_Id in $Entity_Ids) {
    IF ($Entity_Id.DefaultScope -eq $false -and $null -ne $Entity_Id.EntityId) {
        try {
            $SP_Info = Get-AzADServicePrincipal -ObjectId $Entity_Id.EntityId -ErrorAction 'stop'
        }
        catch {
            IF ($_.Exception) {
                # Write-Host -ForegroundColor Yellow "This is not a Az AD Service Principal trying the command: Get-AzADUser"
                IF ($_.Exception -like "*Request_ResourceNotFound*") {
                    try {
                        $SP_Info = Get-AzADUser -ObjectId $Entity_Id.EntityId -ErrorAction 'stop'
                    }
                    catch {
                        IF ($_.Exception -like "*queried reference-property objects are not present*") {
                            try {
                                $SP_Info = Get-AzADGroup -ObjectId $Entity_Id.EntityId -ErrorAction 'stop'
                            }
                            catch {
                                IF ($_.Exception) {
                                    Write-Host -ForegroundColor Yellow $_.Exception
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $Permissions = $Entity_Id.Permissions
    $ServicePrincipal = New-Object PSObject
    $ServicePrincipal | add-member Noteproperty DisplayName $SP_Info.DisplayName
    $ServicePrincipal | add-member Noteproperty EntityId $SP_Info.Id
    $ServicePrincipal | add-member Noteproperty Container $Container
    $ServicePrincipal | add-member Noteproperty Permissions $Permissions
    $ServicePrincipal
}
