CLS

$CSV_Path = "CSV_Path.csv"
$New_PowerShell_FileName = "FileName.ps1"
$New_TaskName = 'Monitor'

Function Create-FullScheduledTask {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [System.IO.FileInfo]$CSV_Path,
    [Parameter()]
    [String]$New_PowerShell_FileName,
    [Parameter()]
    [String]$New_TaskName
    )

Begin{
    $FormatEnumerationLimit="0"
    $CSV_Data = Import-Csv -Path $CSV_Path
    $CSVRowNumber = $CSV_Data.count
    $Values = @(0..$CSVRowNumber)
}

Process {

ForEach ($V in $Values) {
    IF ($CSV_Data[$v] -ne $null) {
        $ServerName = $CSV_Data[$V].ServerNames
        
        $SourceServer = "SourceServer" # AD Server
        $DestinationServer = $ServerName # This is where we will input multiple servers.
        
        IF ((Test-Path "\\$DestinationServer\D`$\AUTO\Splunk") -ne $true) {
            Write-Host -ForegroundColor Yellow $DestinationServer "Path: " "\\$DestinationServer\D`$\AUTO\Splunk" " Does not exist, but is now being created."
            New-Item -ItemType "directory" -Path "\\$DestinationServer\D`$\AUTO\Splunk" -Force
        }

        Copy-Item -Path "\\$SourceServer\D`$\AUTO\Splunk\$New_PowerShell_FileName" -Destination "\\$DestinationServer\D`$\AUTO\Splunk" -Verbose -Force
        
        $MySession = New-PSSession -ComputerName $ServerName

        Invoke-Command -Session $MySession -ScriptBlock {
            #$env:COMPUTERNAME
            $Trigger = (New-ScheduledTaskTrigger -At 4:30AM -Daily -DaysInterval 1)
            $WorkingDirectory = "D:\AUTO\Splunk\"
            $Argument = "D:\AUTO\Splunk\$Using:New_PowerShell_FileName"
            $Action = (New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory $WorkingDirectory -Argument $Argument)
            $Principal = New-ScheduledTaskPrincipal -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount 
            $Settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel
            
            Register-ScheduledTask -TaskName $Using:New_TaskName `
                -Trigger $Trigger `
                -Action $Action `
                -Settings $Settings `
                -Principal $Principal `
                -Force
            }# End Invoke-Command #>
        
        Invoke-Command -Session $MySession -ScriptBlock {
            #Write-host -ForegroundColor Cyan $env:COMPUTERNAME
            IF ((Test-Path "\\$env:COMPUTERNAME\D`$\AUTO\Splunk") -eq $true) {
                Write-host -ForegroundColor Cyan "The Powershell script has been copied over, and the Scheduled task has been set up on the following server: " $env:COMPUTERNAME
            }
        }# End Invoke-Command
    }# END IF ($CSV_Data[$v] -ne $null)
}# END ForEach ($V in $Values)
}# END Process
End {Get-PSSession | Remove-PSSession }# END END
}# END Function 

Create-FullScheduledTask -CSV_Path $CSV_Path -New_PowerShell_FileName $New_PowerShell_FileName -New_TaskName $New_TaskName
