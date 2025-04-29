cls


<#

•	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip Start Value was  set to 2 (Auto Start) 
•	HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AFD  Start Value was also  set to 2( Auto start)

o	TCPIP should be 0 (Boot-start) -> As per default settings
o	AFD should be 1 (system start) -> As per default settings

#>



Function Get-RegistryValues {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

$StoreNumber = ([System.Environment]::MachineName).subString(2,5)

$TcpIPLocation = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip"

$TcpIPValue = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip").start

$AFDLocation = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AFD"

$AFDValue = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AFD").start

IF ($TcpIPValue -ne "0" -or $AFDValue -ne "1") {

    $Status =  "Modified"

}
ELSE {
    
    $Status = "NOT Modified"

}

$Properties = @{'Location Number'  =   $StoreNumber;
                'TcpIP/AFD Default Start Value'         =   $Status;}#END $Properties

IF ($Status -eq "Modified") {
    
        $Output += New-Object -TypeName psobject -Property $Properties

        Write-Output $Output | Format-Table -Property 'Location Number', 'TcpIP/AFD Default Start Value' -AutoSize
}




}#END Process

END {}

}#END Function Get-RegistryValues

Get-RegistryValues

