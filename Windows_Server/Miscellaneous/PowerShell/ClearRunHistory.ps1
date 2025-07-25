<#
.SYNOPSIS
	Clears the run history from a FIM Synchronization Server.
.PARAMETER Days
	Delete entries older than this number of days. The default is 1.
.PARAMETER ServerName
	The name of the FIM Synchronization Server. The default is the local 
    machine.
.PARAMETER Silent
	Do not warn if deleting all entries (might slow down the server).
.DESCRIPTION
	Clears the run history from the specified FIM Synchronization Server,
    deleting all entries older than the specified number of days.
.EXAMPLE
    .\ClearRunHistory.ps1 0 -Silent
    # clear all runs without displaying warnings    
.EXAMPLE
    .\ClearRunHistory.ps1 -Verbose
    # clear all runs older than 1 day and print more execution information
#>
[CmdletBinding()]
param (
    [int] $Days = 5,
    [string] $ServerName = ".",
    [switch] $Silent)

# Get the WMI server object
$fimServer = get-wmiobject -class MIIS_Server -namespace root\MicrosoftIdentityIntegrationServer `
    -ComputerName $ServerName -ErrorAction SilentlyContinue
if ($fimServer -eq $null) {
    Write-Host -ForegroundColor Red "Server not found"
    exit 1
}

if ($Days -eq 0 -and -not $Silent) {
    Write-Warning "Clearing all runs could slow down the system."
    if ($(Read-Host "Continue (Y/N)?").ToUpper() -ne "Y") {
        exit 1
    }
}

# Clear runs that ended before this date (and get date in expected format)
$endingBefore = [System.DateTime]::UtcNow.AddDays(-$days).ToString("yyyy-MM-dd HH:mm:ss.fff")

# Clear MA runs
Write-Verbose "Clearing runs on $ServerName older than $Days days"
$runStart = [System.DateTime]::UtcNow
$res = $fimServer.ClearRuns($endingBefore)
$runTime = [System.DateTime]::UtcNow - $runStart
Write-Verbose "Operation completed in: $runTime."

if ($res.ReturnValue -eq "success") {
    Write-Host "Run history cleared successfully."
    exit 0
} else {
    Write-Host -ForegroundColor Red "Error clearing Management Agent runs: $($res.ReturnValue)."
    exit 1
}

