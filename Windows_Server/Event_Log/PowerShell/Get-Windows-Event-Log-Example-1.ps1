CLS

$DateX = (Get-Date).AddDays(-215)

$Information = "4"

$Warning = "3"

$ErrorX = "2"

$Critical = "1"

Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$DateX; Level=$Critical} | Where {$_.message -like "*Corp_Name*"}
