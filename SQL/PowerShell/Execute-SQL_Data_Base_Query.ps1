CLS


Function Execute-SQL_Data_Base_Query {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
 
# "LocalHost" is how we will call the SQL Server Instance via PS Remote.
# Prerequisite: We will need run a (Install-Module -name SqlServer -force -confirm:$False) on all of the POS Servers inorder for this to work.
$Server = "localhost"
$Database = "LHSITEDB"

# $Time this variable is set to yesterday 
$Time = (Get-Date).ToString('M/d/yyyy 23:59:59:999')

$OldTime = (Get-Date).AddDays(-10000).ToString('M/d/yyyy 23:59:59:999')

$Query = "
SELECT    customer_name, 
          tran_sequence_number,
          status,
          fire_date,
          pickup_datetime
FROM      dbo.Deferred_Order
WHERE     fire_date BETWEEN CONVERT(datetime,'$OldTime') AND CONVERT(datetime,'$Time') and status='Stored'
ORDER by  fire_date
"

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query | Format-Table


}#END Process
END {}#END END
}# END Function Execute-SQL_Data_Base_Query
