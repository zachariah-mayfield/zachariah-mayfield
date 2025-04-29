CLS

# Find out Hard Drive Type 

#EXAMPLE is it a SSD or a regular HD

# WMI Object Class = MSFT_PhysicalDisk  NameSpace = "Root\Microsoft\Windows\Storage"  MediaType 4 = SSD Hard Drive 
Get-WmiObject -class MSFT_PhysicalDisk -namespace "Root\Microsoft\Windows\Storage" | select MediaType

# WMI Object Class = MSFT_PhysicalDisk  NameSpace = "Root\Microsoft\Windows\Storage"  MediaType 3 = HDD Hard Drive 
Get-WmiObject -class MSFT_PhysicalDisk -namespace "Root\Microsoft\Windows\Storage" -Verbose | select MediaType


# PowerShell check to see if the hard drive is a ssd
# Windows 10 PS CMD
get-disk | ? model -match ‘ssd’

# Windows 7 PS CMD
Get-WmiObject win32_diskdrive | where { $_.model -match ‘SSD’}

