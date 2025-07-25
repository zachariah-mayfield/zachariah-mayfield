Clear-host

$Trigger = (New-ScheduledTaskTrigger -At 1:30AM -Daily -DaysInterval 1)
# TIP: file or  Folder names can NOT have  any spaces in them or the Scheduled Taks will not run.
$WorkingDirectory = "C:\Folder"
$Argument = "C:\Folder\Backup.ps1"
$Action = (New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory $WorkingDirectory -Argument $Argument)
$Principal = New-ScheduledTaskPrincipal -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount 
$Settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel
Register-ScheduledTask -TaskName 'Tableau_Backup' `
-Trigger $Trigger `
-Action $Action `
-Settings $Settings `
-Principal $Principal `
-Force

