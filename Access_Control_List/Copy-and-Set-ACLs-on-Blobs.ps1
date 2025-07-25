Clear-Host

IF ($PSVersionTable.PSVersion.Major -lt "7") {
	Write-Host -ForegroundColor Yellow	"Please update your version of powershell to the latest version."
}
elseif ((Get-Command -Name Get-AzDataLakeGen2Item).Source -notmatch "AZ.Storage") {
	Write-Host -ForegroundColor Yellow	"Inorder to run this script you will need to install the PowerShell AZ Module. To do so, open PowerShell as an admin and run the following command:" ' Install-Module -Name AZ -Repository 'PSGallery' -Scope 'CurrentUser' -AcceptLicense -Force -Verbose'
}

$TenantId = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Subscription = "xxxxxxxxxxxx"
$Storage_Account_Name = 'xxxxxxxxxxxxxxxxxxxx'

#Try This filter if the other dosent work "/xxx/"
$Prefix = 'xxxx/'

#$Azure_PassWord = Read-Host "Please enter your Azure Account Password" 
$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "xxx@xxx.xxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
Connect-AzAccount -Credential $Credential -Subscription $Subscription -Tenant $TenantId
$AzStorageContext = New-AzStorageContext -StorageAccountName $Storage_Account_Name -UseConnectedAccount

$AzStorageContainers = ((Get-AZStorageContainer -Context $AzStorageContext ) | Where-Object {$_.Name -like "dd*" -or $_.Name -like "od*"})

ForEach ($AzStorageContainer in $AzStorageContainers.Name) {
    Write-Host -ForegroundColor Cyan "These are the Blobs under the container: " $AzStorageContainer
    $MaxReturn = 10000
    $Total = 0
    $Token = $Null
    Do {
        $Blobs = (Get-AzDataLakeGen2ChildItem -Context $AzStorageContext -FileSystem $AzStorageContainer -MaxCount $MaxReturn -ContinuationToken $Token |
        Where-Object {$_.name -notlike "*/*" -and $_.name -notlike "xxxx"}).name
        $Total += $Blobs.Count
        if($Blobs.Length -le 0) { Break;}
        $Token = $Blobs[$Blobs.Count -1].ContinuationToken;
        Write-Host -ForegroundColor Yellow $Blobs
        $Blob_Check = Get-AzDataLakeGen2ChildItem -Context $AzStorageContext -FileSystem $AzStorageContainer -MaxCount $MaxReturn -ContinuationToken $Token -Path $Prefix
        ForEach ($Blob in $Blobs){
            If ($Blob_Check.Path -notcontains "xxxx/$($Blob)"){
                Write-Host -ForegroundColor red -BackgroundColor white $Blob " $($Prefix) folder does not contain ablob named: $($Blob)"
                New-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $AzStorageContainer -Path "xxxx/$($Blob)/" -Directory -Verbose -WhatIf
            }
            else {
                Write-Host -ForegroundColor cyan $Blob " $($Prefix) folder does contain ablob named: $($Blob)"
            }
            $New_ACL = (Get-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $AzStorageContainer -Path $Blob).ACL 
            Update-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $AzStorageContainer -Path "xxxx/$($Blob)" -ACL $New_ACL -Verbose #-WhatIf
        }
    }
    While ($null -ne $Token)
}
