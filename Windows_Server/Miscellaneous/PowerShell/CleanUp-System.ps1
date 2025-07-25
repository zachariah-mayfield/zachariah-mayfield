Clear-Host


# How to tell if your hard drive is a SSD or not - that way you know which type of Defrag to use.
###########
###########
# WMI Object Class = MSFT_PhysicalDisk  NameSpace = "Root\Microsoft\Windows\Storage"  MediaType 4 = SSD Hard Drive 
Get-WmiObject -class MSFT_PhysicalDisk -namespace "Root\Microsoft\Windows\Storage" | select MediaType

# WMI Object Class = MSFT_PhysicalDisk  NameSpace = "Root\Microsoft\Windows\Storage"  MediaType 3 = HDD Hard Drive 
Get-WmiObject -class MSFT_PhysicalDisk -namespace "Root\Microsoft\Windows\Storage" -Verbose | select MediaType


# PowerShell check to see if the hard drive is a ssd
# Windows 10 PS CMD
get-disk | ? model -match ‘ssd’

# Windows 7 PS CMD
Get-WmiObject win32_diskdrive | where { $_.model -match ‘SSD’}
###########
###########












Function CleanUP {
    Param (
        [Parameter(Mandatory=$True)]
        [Int]$DaysToDelete,    
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName = $Env:COMPUTERNAME
    )
        Process {
        ## $DaysToDelete = How old the data in the Specified folders must be to delete
        $DaysToDelete = 14
        $TimeOfDay = get-date -Format HH
        
        $LogDate = get-date -format "MM-d-yy-HH"
        $LogFile = "C:\ITOC-LogFiles\AAA-$LogDate.log"
        # Creates a record of all or part of a Windows PowerShell session to a text file.
        Start-Transcript -Path $LogFile

#################################################################

$Before = ForEach ($Computer in $ComputerName ) {
            $Culture = New-Object System.Globalization.CultureInfo -ArgumentList "en-us",$false
            $Culture.NumberFormat.PercentDecimalDigits = 4
            $Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $Computer -ErrorAction SilentlyContinue
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -MemberType Noteproperty -Name 'Computer Name:' -Value ($Computer)
            $Obj | Add-Member -MemberType NoteProperty -Name 'Total System Space(GB):' -Value ($Disk.size/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space(GB):' -Value ($Disk.FreeSpace/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space Percentage(GB):' -Value (($Disk.FreeSpace/$Disk.Size).ToString("P", $Culture))
            
            IF ($obj.'System Free Space Percentage(GB):' -lt "5") {$obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold GT 5% :' -Value $True} 
            Else {$obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold LT 5% :' -Value $False}
                    
            $obj | Format-List
        }


#################################################################

## This can be un commented out If you only want to run it Between these times, then this script will run.
# If (( $TimeOfDay -gt "07" ) -or ( $TimeOfDay -lt 22)) {

## Stops the windows update service.  
Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
## Windows Update Service has been stopped successfully! 
 
## Deletes the contents of windows Windows\Prefetch. 
Get-ChildItem "C:\Windows\Prefetch\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of Windows Windows\Prefetch have been removed successfully! 

## Deletes the contents of windows software distribution. 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of Windows SoftwareDistribution have been removed successfully! 

## Deletes the contents of the Windows Temp folder. 
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of Windows Temp have been removed successfully! 

## Deletes the contents of the C: Temp folder. 
Get-ChildItem "C:\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The Contents of C: Temp have been removed successfully! 
              
## Delets all files and folders in user's Temp folder.  
Get-ChildItem "C:\users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of C:\users\$env:USERNAME\AppData\Local\Temp\ have been removed successfully! 

## Delets all files and folders in user's "C:\Users\*\Local Settings\Temp".  
Get-ChildItem "C:\Users\*\Local Settings\Temp" -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of C:\users\$env:USERNAME\AppData\Local\Temp\ have been removed successfully! 
                     
## Remove all files and folders in user's Temporary Internet Files.  
Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
Where-Object {($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete))} | 
remove-item -force -recurse -ErrorAction SilentlyContinue 
## All Temporary Internet Files have been removed successfully! 
                     
## Cleans IIS Logs if applicable. 
Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { ($_.CreationTime -le $(Get-Date).AddDays(-60)) } | 
Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue 
## All IIS Logfiles over x days old have been removed Successfully! 
                   
## deletes the contents of the recycling Bin. 
Clear-RecycleBin -Force 
## The Recycling Bin has been emptied!

################################################################################
# This Automates the Clean Manager for the disk clean up utility.

# The below registry adds a configuration saved under the setting of sagerun:777 and when called it will run automaticlly.
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Content Indexer Cleaner' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameNewsFiles' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameStatisticsFiles' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameUpdateFiles' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Microsoft_Event_Reporting_2.0_Temp_Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -name StateFlags777 -type DWORD -Value 2
Set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -name StateFlags777 -type DWORD -Value 2

# This runs the Disk Clean Up Utility inder the new settings for /SageRun:777
cleanmgr.exe /sagerun:777

################################################################################

#Delete Temporary Internet Files:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8

#Delete Cookies:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2

#Delete History:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1

#Delete Form Data:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 16

#Delete Passwords:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32

#Delete All:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255

#Delete All + files and settings stored by Add-ons:
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351

################################################################################

# Defrag the machine on a Windows 7 machine use the below:
ForEach ($Computer in $ComputerName){
    $Volume = Get-WmiObject -Class Win32_Volume -ComputerName $Computer -Filter "DriveLetter = 'c:'"
    $res = $Volume.Defrag($false)

    IF ($res.ReturnValue -eq 0)
    {
        Write-Host "Defrag succeeded."
    } Else {
        Write-Host "Defrag failed Result code: " $res.ReturnValue
    }
}

################################################################################

## Starts the Windows Update Service 
Get-Service -Name wuauserv | Start-Service -Verbose 


################################################################################

$After = ForEach ($Computer in $ComputerName ) {
            $Culture = New-Object System.Globalization.CultureInfo -ArgumentList "en-us",$false
            $Culture.NumberFormat.PercentDecimalDigits = 4
            $Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $Computer -ErrorAction SilentlyContinue
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -MemberType Noteproperty -Name 'Computer Name:' -Value ($Computer)
            $Obj | Add-Member -MemberType NoteProperty -Name 'Total System Space(GB):' -Value ($Disk.size/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space(GB):' -Value ($Disk.FreeSpace/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space Percentage(GB):' -Value (($Disk.FreeSpace/$Disk.Size).ToString("P", $Culture))
            
            IF ($obj.'System Free Space Percentage(GB):' -lt "5") {$obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold GT 5% :' -Value $True} 
            Else {$obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold LT 5% :' -Value $False}
                    
            $obj | Format-List
        }
        
        Write-Host "Before: " $Before
        Write-Host "After:  " $After


################################################################################

Stop-Transcript
}
}




CleanUP -DaysToDelete 14 -ComputerName $env:COMPUTERNAME