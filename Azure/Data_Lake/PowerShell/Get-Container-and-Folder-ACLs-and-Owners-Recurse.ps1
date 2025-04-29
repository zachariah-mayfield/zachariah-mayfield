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

Function Get-AzDataLakeGen2ChildItem_ACLs {
    Param (
    # Environment Parameter
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Development','Production', ErrorMessage="Chosen Environment is not listed", IgnoreCase=$true)]
    [System.String]$Environment,
    # Storage_Account_Name Parameter
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.String]$Storage_Account_Name,
    # Container Parameter
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.String]$Container,
    # Folder_Prefix Parameter
    [parameter(mandatory=$false)]
    [System.String]$Folder_Prefix,
    # PSCredential Parameter
    [parameter(mandatory=$false)]
    [System.Management.Automation.PsCredential]$PSCredential,
    # Use_Stored_Windows_Credential_Authentication Parameter
    [parameter(mandatory=$false)]
    [Switch]$Use_Stored_Windows_Credential_Authentication,
    # Use_Certificate_Authentication Parameter
    [parameter(mandatory=$false)]
    [Switch]$Use_Certificate_Authentication
    #[System.Boolean]   true/false
    )
Begin{

#region PowerShell Version and Module Check
    IF ($PSVersionTable.PSVersion.Major -lt '7') {
        Write-Host -ForegroundColor Yellow	'Please update your version of powershell to the latest version.'
        # Install latest version of powershell:
        # https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi
    }
    elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
        Write-Host -ForegroundColor Yellow	'In order to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:' ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
    }
#endregion PowerShell Version and Module Check

IF ($Environment -eq 'Development') {
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    #[parameter(mandatory=$false)]
    #[System.IO.FileInfo]$Certificate_Location = 'Cert:\LocalMachine\root\'
    #[parameter(mandatory=$false)]
    #[System.String]$Certificate_Name = "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#region Use_Certificate_Authentication
    IF ($Use_Certificate_Authentication) {
        # Assign the Cert thumbprint to a varriable
        $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\root\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint

        # Verify that the Certificate is created
        IF ($null -eq $CertificateThumbprint) {
            Write-Host -ForegroundColor Yellow "No such Certificate found with the name: $($Certificate_Name) in the location: $($Certificate_Location)"
        }
        IF ($Use_Certificate_Authentication -eq $true) {
            # This connects to Azure with the supplied parameters.
            Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Application_ID -Tenant $Tenant_ID -CertificateThumbprint $CertificateThumbprint | Out-Null
        }
    }
#endregion Use_Certificate_Authentication
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
    #[parameter(mandatory=$false)]
    #[System.IO.FileInfo]$Certificate_Location = 'Cert:\LocalMachine\root\'
    #[parameter(mandatory=$false)]
    #[System.String]$Certificate_Name = "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    # This pulls the (Certificate Thumbprint) from the Certificate path 'Cert:\LocalMachine\root\' that matches the Certificate Subject "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#region Use_Certificate_Authentication
    IF ($Use_Certificate_Authentication) {
        # Assign the Cert thumbprint to a varriable
        $CertificateThumbprint = (Get-ChildItem -Path 'cert:\LocalMachine\root\' | Where-Object {$_.Subject -match "CN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}).Thumbprint

        # Verify that the Certificate is created
        IF ($null -eq $CertificateThumbprint) {
            Write-Host -ForegroundColor Yellow "No such Certificate found with the name: $($Certificate_Name) in the location: $($Certificate_Location)"
        }
        IF ($Use_Certificate_Authentication -eq $true) {
            # This connects to Azure with the supplied parameters.
            Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Application_ID -Tenant $Tenant_ID -CertificateThumbprint $CertificateThumbprint | Out-Null
        }
    }
#endregion Use_Certificate_Authentication
}
Else {
    Write-Host -ForegroundColor Yellow -BackgroundColor Cyan '$Azure_Environment variable not set'
    Exit-PSHostProcess
}
#region Use_Stored_Windows_Credential_Authentication
    IF ($Use_Stored_Windows_Credential_Authentication) {
        $Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
        $UserName = "$($env:username)@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        $EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
        $PSCredential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
        Connect-AzAccount -Credential $PSCredential -Subscription $Subscription_ID -Tenant $Tenant_ID | Out-Null
    }
#endregion Use_Stored_Windows_Credential_Authentication

#region Use PSCredential Authentication
    ElseIF ($PSCredential) {
        # Connect to Azure via either Windows Stored Credential OR $PSCredential
        Connect-AzAccount -Credential $PSCredential -Subscription $Subscription_ID -Tenant $Tenant_ID | Out-Null
    }
#endregion Use PSCredential Authentication
    Else {
        Write-Host -ForegroundColor Yellow "An Authentication type was not selected."
    }

}#END Begin
Process {
#region Azure Storage Context
    # This creates a new Azure Storage Context to use the specified storage account name parameter and with the connected Azure account from above.
    $Azure_Storage_Context = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount
#endregion Azure Storage Context

#region Container Owner
    $C_Owner = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container)

    IF ($C_Owner.Owner -ne '$superuser') {
        try {
            $Container_Owner = (Get-AzADServicePrincipal -ObjectId $C_Owner.Owner -ErrorAction 'Stop').DisplayName
            Write-Host -ForegroundColor Cyan "The owner of the Container $($Container) is: $($Container_Owner)"
        }
        catch { 
            IF ($_.Exception) {
                try {
                    $Container_Owner = (Get-AzADUser -ObjectId $C_Owner.Owner -ErrorAction 'Stop').DisplayName
                    Write-Host -ForegroundColor Cyan "The owner of the Container $($Container) is: $($Container_Owner)"
                }
                catch {
                    IF ($_.Exception) {
                        try {
                            $Container_Owner = (Get-AzADGroup -ObjectId $C_Owner.Owner -ErrorAction 'Stop').DisplayName
                            Write-Host -ForegroundColor Cyan "The owner of the Container $($Container) is: $($Container_Owner)"
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
    Else {
        Write-Host -ForegroundColor Cyan "The owner of the Container $($Container) is: $($C_Owner.Owner)"
        $Container_Owner = '$superuser'
    }
#endregion Container Owner

#region Container ACLs
    $Container_Entity_Ids = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container).acl | Where-Object {$null -ne $_.EntityId -and $_.DefaultScope -eq $false}

    ForEach ($Container_Entity_Id in $Container_Entity_Ids) {
        IF ($Container_Entity_Id.DefaultScope -eq $false -and $null -ne $Container_Entity_Id.EntityId) {
            try {
                $Container_Info = Get-AzADServicePrincipal -ObjectId $Container_Entity_Id.EntityId -ErrorAction 'stop'
            }
            catch {
                IF ($_.Exception) {
                    # Write-Host -ForegroundColor Yellow "This is not a Az AD Service Principal trying the command: Get-AzADUser"
                    IF ($_.Exception -like "*Request_ResourceNotFound*") {
                        try {
                            $Container_Info = Get-AzADUser -ObjectId $Container_Entity_Id.EntityId -ErrorAction 'stop'
                        }
                        catch {
                            IF ($_.Exception -like "*queried reference-property objects are not present*") {
                                try {
                                    $Container_Info = Get-AzADGroup -ObjectId $Container_Entity_Id.EntityId -ErrorAction 'stop'
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
        $Permissions = $Container_Entity_Id.Permissions
        $Service_Principal = New-Object PSObject
        $Service_Principal | add-member Noteproperty Container_User_DisplayName $Container_Info.DisplayName
        $Service_Principal | add-member Noteproperty Container_User_EntityId $Container_Info.Id
        $Service_Principal | add-member Noteproperty Container_User_Permissions $Permissions
        $Service_Principal | add-member Noteproperty Container $Container
        $Service_Principal | add-member Noteproperty Container_Owner $Container_Owner
        $Service_Principal
    }
#endregion Container ACLs

#region Folder ACLs
    $Folder_Paths = ((Get-AzDataLakeGen2childItem -Context $Azure_Storage_Context -FileSystem $Container -Recurse) | Where-Object {$_.IsDirectory -eq $true}).Path

    ForEach ($Folder in $Folder_Paths) {
        $Entity_Ids = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container -Path $Folder).acl | Where-Object {$null -ne $_.EntityId -and $_.DefaultScope -eq $false}
        $Folder_Owner = $null
        $SP_Info = $null
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

            $F_Owner = (Get-AzDataLakeGen2Item -Context $Azure_Storage_Context -FileSystem $Container -Path $Folder)
#endregion Folder ACLs

#region Folder Owner
            IF ($F_Owner.Owner -ne '$superuser') {
                try {
                    $Folder_Owner = (Get-AzADServicePrincipal -ObjectId $F_Owner.Owner -ErrorAction 'Stop').DisplayName
                    Write-Host -ForegroundColor Cyan "The owner of the Folder $($Folder) is: $($Folder_Owner)"
                }
                catch { 
                    IF ($_.Exception) {
                        try {
                            $Folder_Owner = (Get-AzADUser -ObjectId $F_Owner.Owner -ErrorAction 'Stop').DisplayName
                            Write-Host -ForegroundColor Cyan "The owner of the Folder $($Folder) is: $($Folder_Owner)"
                        }
                        catch {
                            IF ($_.Exception) {
                                try {
                                    $Folder_Owner = (Get-AzADGroup -ObjectId $F_Owner.Owner -ErrorAction 'Stop').DisplayName
                                    Write-Host -ForegroundColor Cyan "The owner of the Folder $($Folder) is: $($Folder_Owner)"
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
            Else {
                Write-Host -ForegroundColor Cyan "The owner of the Folder $($Folder) is: $($F_Owner.Owner)"
                $Folder_Owner = '$superuser'
            }
#endregion Folder Owner
            $Permissions = $Entity_Id.Permissions
            $ServicePrincipal = New-Object PSObject
            $ServicePrincipal | add-member Noteproperty Folder_User_DisplayName $SP_Info.DisplayName
            $ServicePrincipal | add-member Noteproperty Folder_User_EntityId $SP_Info.Id
            $ServicePrincipal | add-member Noteproperty Folder_Path $Folder
            $ServicePrincipal | add-member Noteproperty Folder_User_Permissions $Permissions
            $ServicePrincipal | add-member Noteproperty Folder_Owner $Folder_Owner
            $ServicePrincipal | add-member Noteproperty Container $Container
            $ServicePrincipal | add-member Noteproperty Container_Owner $Container_Owner
            $ServicePrincipal
        }
    }
}#END Process
End {}#End END
}#END Function

Get-AzDataLakeGen2ChildItem_ACLs -Environment 'Production' -Use_Stored_Windows_Credential_Authentication -Storage_Account_Name 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -Container 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
