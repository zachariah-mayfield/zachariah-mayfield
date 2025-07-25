CLS



Function Get-OracleQuery {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$UserName = "xxxxx",
    [Parameter()]
    [String]$Password = "xxxxx",
    [Parameter()]
    # "//HOST:PORT/Instance.Domain.com"
    [String]$DataSource = "//xxxxx",
    [Parameter()]
    [String]$OracleManagedDataAccessDLLPath = "C:\xxxxx\Oracle.ManagedDataAccess.dll"
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$Connection = $null

# This add the appropiate DLL to be able to give you the .NET Commands to be able to access the Oracle DataBase.
Add-Type -Path $OracleManagedDataAccessDLLPath

# This creates your connection string for your connection.
$Connection_String = "User Id=$UserName;Password=$Password;Data Source=$DataSource"

# This creates your connection to the Oracle DataBase.
$Connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($Connection_String)

# This opens your connection to the database.
$Connection.Open()  

# This is your command Variable to allow you to run commands for querying the oracle database.
$Command = $Connection.CreateCommand()

$Today = (Get-date).ToString('dd-MMM-yyyy') 

# This is you Query syntax.
$Command.CommandText = "SELECT * from APPS.xxxxx_ATTRIBUTE_VALUES_V
WHERE ATTRIBUTE_ID = 12345 AND END_DATE > to_date('$Today', 'DD-MON-YYYY')
ORDER BY END_DATE"

# this executes the command query, and stores it in a reader variable to be looped through.
$Reader = $Command.ExecuteReader()

}

Process {

$Array_Properties = @()

# This is a While loop to loop though all of the values for each of the rows and columns in the database table.
While ($Reader.Read()) {

    for ($ColumnNum=0;$ColumnNum -lt $Reader.FieldCount;$ColumnNum++) {
        #Write-Host  $Reader.GetName($ColumnNum) $Reader.GetValue($ColumnNum)
        $Properties += @{$Reader.GetName($ColumnNum) = $Reader.GetValue($ColumnNum);}
    }

    $Output = New-Object -TypeName psobject -Property $Properties

    Write-Output $Output 
    $Array_Properties += $Properties
    $Properties=$null
    
}#END While ($Reader.Read())

}#END Process

END {
$Connection.Close()
}#END END

}#END Function Get-OracleQuery


