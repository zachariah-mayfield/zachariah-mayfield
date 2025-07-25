CLS

(Get-CimInstance Win32_LogicalDisk -filter "DriveType=4").ProviderName
(Get-CimInstance Win32_LogicalDisk -filter "DriveType=4").DeviceID

(Get-PSDrive -Name Z).DisplayRoot

net use Z: \\dept.nas.Company.com\dept\Public\Username /persistent:yes

$Network = New-Object -ComObject "Wscript.Network"
$Network.MapNetworkDrive("Z:", "\\dept.nas.Company.com\dept\Public\Username")

Get-WmiObject Win32_MappedLogicalDisk 


$DriveLetter = "Z:","H:","Y:"

Foreach ($Letter in $DriveLetter) {
    $DrivePath = (((Net use $Letter) | Select-String "Remote Name").Line).TrimStart("Remote name") 
    $DrivePath
}
