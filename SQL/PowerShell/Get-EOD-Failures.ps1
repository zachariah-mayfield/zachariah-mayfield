CLS

Function Get-EOD_Failures {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
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

# Test POS Server is "number.POS.Company-x.com" 
# "LocalHost" is how we will call the SQL Server Instance via PS Remote.
# Prerequisite: We will need run a (Install-Module -name SqlServer -force -confirm:$False) on all of the POS Servers inorder for this to work.
$Server = "localhost"
$Database = "siteDB"

# $Time this variable is set to yesterday 
$Time = (Get-Date).AddDays(-1).ToString('M/d/yyyy 23:59:59:999')

$OldTime = (Get-Date).AddDays(-10000).ToString('M/d/yyyy 23:59:59:999')

$Query = "
SELECT    customer_name, 
          tran_sequence_number,
          status,
          fire_status,
          fire_date,
          pickup_datetime
FROM      dbo.Deferred_Order
WHERE     fire_date BETWEEN CONVERT(datetime,'$OldTime') AND CONVERT(datetime,'$Time') and status='Stored'
ORDER by  fire_date
"

$CheckOldDeferredOrders = (Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query | Format-List)

If ($CheckOldDeferredOrders) {
    Write-Output ("There are Old Deferred Orders.")
    Write-Output (" ")
    Write-Output ($CheckOldDeferredOrders)
    Write-Output (" ")
}
ELSE {
    Write-Output ("There are not any Old Deferred Orders.")
}

$Query2 = "
SELECT    customer_name, 
          tran_sequence_number,
          status,
          fire_status,
          fire_date,
          pickup_datetime
FROM      dbo.Deferred_Order 
WHERE     status = 'stored' and fire_status = '1'
"

$CheckFutureDeferredOrders = (Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query2 | Format-List)

If ($CheckFutureDeferredOrders) {
    Write-Output ("There are Flagged Future Deferred Orders.")
    Write-Output (" ")
    Write-Output ($CheckFutureDeferredOrders)
    Write-Output (" ")
}
ELSE {
    Write-Output ("There are not any Flagged Future Deferred Orders.")
}

}#END Process
END {}#END END
}# END Function Get-EOD_Failures


Get-EOD_Failures
