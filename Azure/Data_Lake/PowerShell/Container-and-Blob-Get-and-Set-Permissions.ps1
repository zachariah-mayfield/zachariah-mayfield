Clear-Host

$Update_ACL_Permissions = $true

$TenantId = "xxxxxxxxxxxxxxxxxxxxxxx"
$Subscription = "xxxxxxxxxxxxxxxxxxxx"
$Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxx'
$Container = 'xxxxxxxxxxxxxxxxxxxx'
# This is where the permisssions come from.
$Original_Blob = 'xxxxxxxxxxxxxxxxxxxx'
#Try This filter if the other dosent work "/xxxxxxxxxxxxxxxxxxxx/"
$Prefix = 'xxxxxxxxxxxxxxxxxxxx/'

$Azure_PassWord = Read-Host "Please enter your Azure Account Password" 
#$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "xxxxxxxxxxxxxxxxxxxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
Connect-AzAccount -Credential $Credential -Subscription $Subscription -Tenant $TenantId
$AzStorageContext = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

#$AzStorageContainers = (Get-AZStorageContainer -Context $AzStorageContext ) | Where-Object {$_.Name -like "dd*" -or $_.Name -like "od*"} 
#$AzStorageContainers
 
$ACLs = (Get-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container -Path $Original_Blob).acl | Where-Object {$null -ne $_.EntityId -and $_.DefaultScope -eq $false}
$AzStorageBlobPath = (Get-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container -Path $Original_Blob).Path

# this is where the sub blobs come from.
$AzStorageBlobs = (Get-AzStorageBlob -Context $AzStorageContext -Container $Container -Prefix $Prefix).Name

ForEach ($Acl in $ACLs){
    IF ($Acl.DefaultScope -eq $false -and $null -ne $Acl.EntityId) {
        try {
            $SP_Info = Get-AzADServicePrincipal -ObjectId $Acl.EntityId -ErrorAction 'stop'
        }
        catch {
            IF ($_.Exception) {
                # Write-Host -ForegroundColor Yellow "This is not a Az AD Service Principal trying the command: Get-AzADUser"
                IF ($_.Exception -like "*Request_ResourceNotFound*") {
                    try {
                        $SP_Info = Get-AzADUser -ObjectId $Acl.EntityId -ErrorAction 'stop'
                    }
                    catch {
                        IF ($_.Exception) {
                            Write-Host -ForegroundColor Yellow $_.Exception
                        }
                    }
                }
            }
        }
        $Permissions = $Acl.Permissions
        $ServicePrincipal = New-Object PSObject
        $ServicePrincipal | add-member Noteproperty DisplayName $SP_Info.DisplayName
        $ServicePrincipal | add-member Noteproperty ID $SP_Info.Id
        $ServicePrincipal | add-member Noteproperty Container $Container
        $ServicePrincipal | Add-Member NoteProperty AzStorageBlobPath $AzStorageBlobPath
        $ServicePrincipal | add-member Noteproperty Permissions $Permissions
        $ServicePrincipal
        
        IF ($Update_ACL_Permissions -eq $true) {
            IF ($ServicePrincipal.Permissions -like "*Read*") {
                $Read = "r"
            }
            else {
                $Read = "-"
            }
            IF ($ServicePrincipal.Permissions -like "*Write*") {
                $Write = "w"
            }
            else {
                $Write = "-"
            }
            IF ($ServicePrincipal.Permissions -like "*Execute*") {
                $Execute = "x"
            }
            else {
                $Execute = "-"
            }
            $New_ACL_Permissions = "{0}{1}{2}" -f $Read,$Write,$Execute

            $New_ACL = (Get-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container -Path $Original_Blob).ACL

            #$New_ACL = New-AzDataLakeGen2ItemAclObject -AccessControlType user -Permission 
            #$New_ACL = New-AzDataLakeGen2ItemAclObject -AccessControlType group -Permission rw- -InputObject $New_ACL
            #$New_ACL = = New-AzDataLakeGen2ItemAclObject -AccessControlType other -Permission  -InputObject $New_ACL

            $New_ACL = Set-AzDataLakeGen2ItemAclObject -AccessControlType user -EntityId $ServicePrincipal.ID -Permission $New_ACL_Permissions -InputObject $New_ACL
            #Update-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container -Path 'delta/' -ACL $New_ACL -Verbose
            ForEach ($AzStorageBlob in $AzStorageBlobs) {
                Update-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container -Path $AzStorageBlob -ACL $New_ACL -Verbose
            }
        }
    }
}
#>
