Set-ExecutionPolicy RemoteSigned -force

Function Start-AzCopy {
  [CmdletBinding()]
  Param (
    # $Subscription_ID: 'Your-Azure-Subscription-ID'
    [Parameter(Mandatory=$true)
    [ValidateSet('Your-Azure-Development-Subscription-ID', 'Your-Azure-UAT-Subscription-ID', 'Your-Azure-Production-Subscription-ID')]
    [string]$Subscription_ID,
    # $Tenant_ID: 'Your-Azure-Tenant-ID'
    [Parameter(Mandatory=$true)]
    [string]$Tenant_ID,
    # $Service_Principal: 'Your_Azure_Service_Principal_Name'
    [Parameter(Mandatory=$true)]
    [string]$Service_Principal,
    # $Object_ID: 'Your-Azure-Object-ID'
    [Parameter(Mandatory=$true)]
    [string]$Object_ID,
    # $Client_ID: 'Your-Azure-Client-ID'
    [Parameter(Mandatory=$true)]
    [string]$Client_ID,
    # $Secret: 'Your-Azure-Secret'
    [Parameter(Mandatory=$true)]
    [string]$Secret,
    # $Resource_Group: 'Your_Azure_Resource_Group_Name'
    [Parameter(Mandatory=$true)]
    [string]$Resource_Group,
    # $Application_ID: 'Your-Azure-Application-ID'
    [Parameter(Mandatory=$true)]
    [string]$Application_ID,
    # $Storage_Account: 'Your_Azure_Storage_Account_Name'
    [Parameter(Mandatory=$true)]
    [string]$Storage_Account,
    # $Storage_Container: 'Your_Azure_Storage_Container_Name'
    [Parameter(Mandatory=$true)]
    [string]$Storage_Container,
    # $Blob_File: 'Your_Blob_Full_File_Path_and_Name_and_Extension'
    [Parameter(Mandatory=$true)]
    [string]$Blob_File
  )

  Begin {
    # Set the Security Protocol Type
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Try {
      Test-Path -Path "C:\AzCopy.exe" -PathType Leaf -ErrorAction Stop
    }# END TRY
    Catch {
      IF ($Error[0].Exception.Message -ne $null) {
        $Error_Exception = ($_.Exception | Select *)
      }# END IF
      Exit
    }# END Catch
  }# END Begin

  Process {
    $SAS_URL = "https://$(Storage_Account).blob.core.windows.net/$($Storage_Container)/"
    Write-Output "AzCopy Upload file: $($Blob_File) to Azure Storage Account: $($Storage_Account) to the container: $($Storage_Container)"
    $env:AZCOPY_SPA_CLIENT_SECRET = $Secret
    C:\AzCopy.exe login --service-principal $Service_Principal --application-id $Application_ID --tenant-id $Tenant_ID
    C:\AzCopy.exe copy $Blob_File $SAS_URL

    $AzBlob_List = ($C:\AzCopy.exe list $SAS_URL --properties 'LastModifiedTime' | Where-Object {$_ -like "*.tsbak" -or $_ -like "*.json"})

    $AzBlobs = ForEach ($AzBlob in $AzBlob_List) {
      $New_AzBlob = ($AzBlob) -split ";"
      $New_AzBlob_Name_Object = [PSCustomObject]@{
        AzBlobName = ($New_AzBlob -replace "INFO: " -split ",")[0]
        LastModifiedTime = [datetime]((($New_AzBlob -replace " LastModifiedTime: ") -replace '\+' -replace '0000 GMT' -split ",")[1])
      }# END $New_AzBlob_Name_Object
      $New_AzBlob_Name_Object
    }# END ForEach
    $Old_Files = ($New_AzBlob_Name_Object | Where-Object {$_.AzBlobName -like "*.json" -or $_.AzBlobName -like "*.tsbak" -and $_.LastModifiedTime -lt (Get-Date).AddDays(-8)}).AzBlobName

    ForEach ($Old_File in $Old_Files) {
      $SAS_URL_Remove_Blob = "https://$(Storage_Account).blob.core.windows.net/$($Storage_Container)/$($Old_File)"
      Write-Output "AzCopy REMOVE file: $($Old_File) from Azure Storage Account: $($Storage_Account) from the container: $($Storage_Container)"
      C:\AzCopy.exe rm $SAS_URL_Remove_Blob --dry-run
    }# END ForEach
  }# END Process
  End {}
}# END Function Start-AzCopy
