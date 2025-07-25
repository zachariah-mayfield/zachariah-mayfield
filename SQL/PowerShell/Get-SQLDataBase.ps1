Clear-Host


Function Get-XXXSQLDataBase {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

$Server = "xxxxx"

$Database = "xxxxx"
$Trusted_Connection = "True"
$UserID = "xxxxx"
$Password = "xxxxx"

$connectionString = "Server = $Server ; Database = $Database ; Integrated Security=True"

$query = "
SELECT    r_name, 
          t_number,
          status,
          e_date,
          p_datetime,
          last_modified_timestamp
FROM      dbo.d_Order
ORDER by  e_date
" 

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText  = $query

$result = $command.ExecuteReader()

$table = new-object “System.Data.DataTable”
$table.Load($result)

$format = @{Expression={$_.customer_name};Label="Customer name";width=20},
@{Expression={$_.tran_sequence_number};Label="tran sequence number"; width=20},
@{Expression={$_.status};Label="status"; width=10},
@{Expression={$_.e_date};Label="e_date"; width=25},
@{Expression={$_.pickup_datetime};Label="Pickup datetime"; width=25},
@{Expression={$_.last_modified_timestamp};Label="last modified timestamp"; width=25}

$Time = (Get-Date).AddDays("-1")

$table | Where-Object {$_.e_date -lt $Time } | format-table $format

#Out-File C:\xxxxx.TXT

$connection.Close()

}#END Process
END {}#END END
}# END Function Get-XXXSQLDataBase

Get-XXXSQLDataBase