CLS

$Connection = $null

add-type -Path "C:\xxxxx\Oracle.ManagedDataAccess.dll"

$UserName = "xxxxx"
$Password = "xxxxx"
$DataSource = "//xxxxx"
$Connection_String = "User Id=$UserName;Password=$Password;Data Source=$DataSource"

$Connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($Connection_String)

$Connection.Open()  

$Query = "
BEGIN 
INSERT INTO xxxxx_ATTRIBUTES (LOCATION_NUM)
Values ('123456');
END;
"

$Command = New-Object Oracle.ManagedDataAccess.Client.OracleCommand($Query, $Connection)

$Reader = $command.ExecuteReader()

$Reader.GetString(0)

while ($Reader.Read()) {
    $Reader.GetString(0)
}