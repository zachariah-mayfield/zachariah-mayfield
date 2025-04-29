<#
.SYNOPSIS
    Function Get-CPU_Utilization
  
.NAME
    Get-CPU_Utilization

.AUTHORS


.DESCRIPTION
    This Function is designed to get the current CPU Utilization and the Top 5 processes running currently.
  
.EXAMPLE
    Get-CPU_Utilization 
  
.PARAMETER -ComputerName
    The ComputerName parameter will query the information on the computername listed.

.NOTE(s)

#>

Function Get-CPU_Utilization {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        #[ValidateNotNullOrEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [string]$ProcessName, 
        [int]$SelectFirst,
        # Switch parameters are $false if you don't specify them on the command line, and are $true if you do specify them on the command line.
        [switch]$GridView
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

#################################################################################

$RandomID = Get-Random
Start-Job -Name $RandomID -ScriptBlock {
    $ParentPID = (Get-Process -IncludeUserName * | Where-Object {$_.username -match "Service_Name" -and $_.ProcessName -notmatch "host"})
    Start-Sleep -Seconds 300
    Write-Host  -ForegroundColor Yellow "Now Ending all Processes running under Service_Name account and stoping the Jobs"
    IF ($ParentPID.Responding -eq "True") {
        "$ParentPID " + "Process is currently running under the username: Service_Name"
    } Else {
        "$ParentPID" + "No Processes are currently running under the username: Service_Name"
    }
    Write-host -ForegroundColor Yellow "$ParentPID" + " Process is stoping"
    $ParentPID | Stop-Process -Force -Verbose
} | Receive-Job | Remove-Job -Force

write-host "`n"

#################################################################################

ForEach ($Computer in $ComputerName){

If (-not $ProcessName) { $ProcessName = '*' }
If (-not $SelectFirst) { $SelectFirst = 5 }

If ($ProcessName -eq '*') {
  $ProcessList = gwmi Win32_PerfFormattedData_PerfProc_Process | select IDProcess,Name,PercentProcessorTime | 
  where { $_.Name -ne "_Total" -and $_.Name -ne "Idle"} | 
  sort PercentProcessorTime -Descending | 
  select -First $SelectFirst
} Else {
  $ProcessList = gwmi Win32_PerfFormattedData_PerfProc_Process | 
  where {$_.Name -eq $ProcessName} | 
  select IDProcess,Name,PercentProcessorTime | 
  sort PercentProcessorTime -Descending | select -First $SelectFirst
}
# The @( opens an array @() simply creates an empty array.
$TopProcess = @()
ForEach ($Process in $ProcessList) {
  $row = new-object PSObject -Property @{
    Id = $Process.IDProcess
    Name = $Process.Name
    ProcessNameX = (gwmi Win32_Process  | where {$_.ProcessId -eq $Process.IDProcess}| Select ProcessName)
    User = (gwmi Win32_Process | where {$_.ProcessId -eq $Process.IDProcess}).GetOwner().User
    CPU = $Process.PercentProcessorTime
    Description = (Get-Process -ID $Process.IDProcess).Description
  }
  $row.ProcessNameX = $row.ProcessNameX.ProcessName.Replace("@{ProcessName=","").Replace("}","")
  $TopProcess += $row
}

If ($GridView) {
  $TopProcess | sort CPU -Descending | select Id,ProcessNameX,Name,User,CPU,Description | Out-GridView
}
Else {
  $TopProcess | sort CPU -Descending | select Id,ProcessNameX,Name,User,CPU,Description | ft -AutoSize
}
}# END ForEach ($Computer in $ComputerName) #1
}# END Proccess
END {}
}# END Function Get-CPU_Utilization
