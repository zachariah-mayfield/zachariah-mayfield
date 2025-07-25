CLS

$Connection = $null

add-type -Path "C:\Oracle.ManagedDataAccess.dll"

$UserName = "xxxx"
$Password = "xxx"
$DataSource = "//xxx.com"
$Connection_String = "User Id=$UserName;Password=$Password;Data Source=$DataSource"

$Connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($Connection_String)

$Connection.Open()  
