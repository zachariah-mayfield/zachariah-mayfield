
Function Get-HardDiskHealth {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

#############################################################################################################################################

# Runs a Check Disk and suppresses the output.
chkdsk 2>&1 | Out-Null

#############################################################################################################################################

# Gets the last check desk that was ran.
$chkdskresult = get-eventlog -logname application -source chkdsk -Newest 1 -AsBaseObject | select -ExpandProperty Message

IF ($chkdskresult -match "([0-9]+) KB in bad sectors.") {
   $CHKDSKResults = "CHKDSK Results:" + $Matches[0]
}

If ($chkdskresult | select-string "0 KB in bad sectors") {
    $chkdskstatus = "CHKDSK Results: There are 0 KB in bad sectors, CHKDSK Results are OK"
} Else {
    $chkdskstatus = "CHKDSK Results: CHKDSK Error(s) Found."
    write-host "`n"   
    write-host "Server Needs Replacement"
}
#############################################################################################################################################

# Removing the below temporarily. 

<#

$A = ([array]$chkdskresult) 

If ($A -like "*An unspecified error occurred*") {
    Write-Host "An Error occured during CHKDSK, and it could not finish."
    write-host "`n"   
    write-host "Server Needs Replacement"
} Else {
    Write-Host "CHKDSK Finished Successfully."
}

#>

##############################################################################################################################################
# Gets the Status of the disk drive.
$GWMI_DriveStatus = (Get-WmiObject -Class win32_diskdrive).Status 

If ($GWMI_DriveStatus | select-string "OK") {
    $DriveStatus = "Drive Status: Status is OK"
} Else {
    $DriveStatus = "Drive Status: Error Found."
     write-host "`n"   
     write-host "Server Needs Replacement"
}
#############################################################################################################################################

# Counts the number of Disk events in the event log.

$Counter =  (get-eventlog -logname system -source disk -entrytype Error,Warning -after (get-date).adddays(-7) -ErrorAction SilentlyContinue | measure).count

$dskeventstatus = "There are "+$Counter+" Disk Events in Event Log"

IF ($Counter -ge 200){
    write-host "Server Needs Replacement"
}

$CheckVolume = (fsutil dirty query C:)

IF ($CheckVolume -eq "Volume - C: is NOT Dirty") {
    $FsutilResults = Write-Output "FSUTIL Scan did not report any errors"
} ELSE {
    $FsutilResults = Write-Output "FSUTIL Scan reported that the drive is in a dirty bit status and auto check disk will be scheduled to run on the next POS Reboot." 
     write-host "`n"   
     write-host "Server Needs Replacement"
}
##############################################################################################################################################

$FsutilResults
$chkdskstatus
$CHKDSKResults
$DriveStatus
$dskeventstatus


}# END Process

END {}# END END
}# END Function Get-HardDiskHealth
