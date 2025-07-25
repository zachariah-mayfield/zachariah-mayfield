CLS

Function Start-BackUpDeferredOrders {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = "SilentlyContinue"
### Added by Eric Turpin to expose invoke-sqlcmd cmdlet
Import-Module sqlps -cmdlet Invoke-Sqlcmd
Get-Command invoke-sqlcmd | ForEach-Object {$_.Visibility = 'Public'}
### Added by Eric Turpin to expose invoke-sqlcmd cmdlet
}#END BEGIN
Process{

# Test POS Server is "90192.POS.Company-x.com" 
# "LocalHost" is how we will call the SQL Server Instance via PS Remote.
# Prerequisite: We will need run a (Install-Module -name SqlServer -force -confirm:$False) on all of the POS Servers inorder for this to work.
$Server = "localhost"
$Database = "LHSITEDB"

# $Time this variable is set to yesterday 
$Time = (Get-Date).AddDays(-1).ToString('M/d/yyyy 23:59:59:999')

$OldTime = (Get-Date).AddDays(-10000).ToString('M/d/yyyy 23:59:59:999')

$Path = "C:\Program Files\Radiant\Lighthouse\Data\"

# Check to make sure that no XML files with a name like DeferredOrder1234567.XML exist in "C:\Program Files\Radiant\Lighthouse\Data\" 
$FileCheck = (Get-ChildItem -Path $Path | Where {$_ -like "DeferredOrder*.XML"} | Select Name).Name

$Query = "
SELECT    customer_name, 
          tran_sequence_number,
          status,
          fire_status,
          fire_date
FROM      dbo.Deferred_Order 
WHERE     status = 'stored'
"

$CheckDeferredOrders = (Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query | Format-List)

IF ([string]::IsNullOrEmpty($CheckDeferredOrders)) {
    Write-Output ("Back up could not start, because there are no deferred orders.")
}

IF (-not ([string]::IsNullOrEmpty($FileCheck))) {
     
    Write-Output ("Back up could not start, because there is already a back up running.")
}

IF (-not ([string]::IsNullOrEmpty($CheckDeferredOrders)) -and [string]::IsNullOrEmpty($FileCheck)) {
    Write-Output ($CheckDeferredOrders)
    $FolderDate = Get-Date -UFormat "%Y-%m-%d"
    IF (Test-Path "C:\Program Files (x86)") {
        $BackupLocation ="C:\Program Files (x86)\Radiant\Lighthouse\Data\deferred_order_backup\ManualBackup_$FolderDate"
    } 
    ELSE {
        $BackupLocation ="C:\Program Files\Radiant\Lighthouse\Data\deferred_order_backup\ManualBackup_$FolderDate"
    }
    TRY {
        BackupDeferredOrdersUtil -BackupDir $BackupLocation 
    }
    CATCH {
        $_
    }
}



}#END Process
END {}#END END
}# END Function Start-BackUpDeferredOrders

Start-BackUpDeferredOrders
