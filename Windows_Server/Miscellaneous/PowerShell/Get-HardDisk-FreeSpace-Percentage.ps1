CLS

Function Get-HardDisk_FreeSpace_Percentage {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(Mandatory=$true)]
    [int]$NumOF_GB_Threshold,
    [Parameter()]
    [Switch]$Create_EventLog
    )
Begin {
    $FormatEnumerationLimit="0"
}
Process {
$Disks = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2"
$Results = foreach ($Disk in $Disks) {
    If ($Disk.Size -gt 0) {
        $Size = [System.Math]::Round($Disk.Size/1GB, 3)
        $FreeSpace = [System.Math]::Round($Disk.FreeSpace/1GB, 3)
        $Disk_Over_Threshold = $false
        #IF ((("{0:P3}") -f ($FreeSpace/$Size)) -lt $NumOF_GB_Threshold){
        IF ((("{0:N3}") -f ($FreeSpace)) -lt $NumOF_GB_Threshold){
            $Disk_Over_Threshold = $true
        }
        IF ($Create_EventLog -eq $false) {
            $DiskProperties = New-Object -TypeName PSObject
            $DiskProperties | Add-Member -MemberType NoteProperty -Name ”Drive Letter” -Value ($Disk.Name)
            $DiskProperties | Add-Member -MemberType NoteProperty -Name "Total Disk Size" -Value (("{0:N3} GB") -f ($Size))
            $DiskProperties | Add-Member -MemberType NoteProperty -Name "Free Disk Size" -Value (("{0:N3} GB") -f ($FreeSpace))
            $DiskProperties | Add-Member -MemberType NoteProperty -Name "Disk Percentage Available" -Value (("{0:P3}") -f ($FreeSpace/$Size))
            $DiskProperties | Add-Member -MemberType NoteProperty -Name "Disk Over Threshold" -Value ($Disk_Over_Threshold)
            $DiskProperties
        }
        #IF ($Create_EventLog -eq $true -and (("{0:P3}") -f ($FreeSpace/$Size)) -lt $NumOF_GB_Threshold) {
        IF ($Create_EventLog -eq $true -and (("{0:N3}") -f ($FreeSpace)) -lt $NumOF_GB_Threshold) {
            #New-EventLog -LogName X_xCustomSplunkAlertsx -Source HardDisk_FreeSpace_Monitor -ErrorAction SilentlyContinue
            $Message = [Ordered]@{}
            $Message.add( "DriveLetter", (”Drive Letter: ” + [String]$Disk.Name))
            $Message.add( " BlankLine1",("
"))
            $Message.add( "TotalDiskSize", (”Total Disk Size: ” + [String](("{0:N3} GB") -f ($Size))))
            $Message.add( " BlankLine2",("
"))
            $Message.add( "FreeDiskSize", (”Free Disk Size: ” + [String](("{0:N3} GB") -f ($FreeSpace))))
            $Message.add( " BlankLine3",("
"))
            $Message.add( "DiskPercentageAvailable", (”Disk Percentage Available: ” + [String](("{0:P3}") -f ($FreeSpace/$Size))))
            $Message.add( " BlankLine4",("
"))
            $Message.add( "DiskOverThreshold", (”Disk Over Threshold: ” + [String]($Disk_Over_Threshold)))
            $Message.add( " BlankLine5",("
"))
            #Write-EventLog -LogName X_xCustomSplunkAlertsx -Source HardDisk_FreeSpace_Monitor -EntryType Warning -EventId 9999 -Message $Message.Values
            $Message
        }
    }
}
$Results | Format-Table -AutoSize
}
END{}
}#END Function

Get-HardDisk_FreeSpace_Percentage -NumOF_GB_Threshold 10
#Get-HardDisk_FreeSpace_Percentage -NumOF_GB_Threshold 10 -Create_EventLog
