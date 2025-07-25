
Function PingDevice {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$Name
    )
Begin{}#END BEGIN
Process{

# PING 
Test-Connection -ComputerName $Name | Select -Property Address,IPV4Address,ResponseTime

}#END Process
END {}#END END
}# END Function PingDevice
