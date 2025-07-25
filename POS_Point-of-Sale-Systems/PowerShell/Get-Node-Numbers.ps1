
Function Get-NodeNumbers {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$Path = "C:\Program Files\Radiant\Lighthouse\Data\LHStationConfig.xml"
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

[String]$Path = $Path

[XML]$XML = Get-Content -Path $Path 

$NodeNumbers = $XML.LHUpdate.Device_Setup.stations.station.station_number

$NodeType = $XML.LHUpdate.Device_Setup.stations.station.station_name 

$REGEX = "(\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b)"

$Output = @()

ForEach ($Number in $NodeNumbers) {

$IPAddressX = ((cinfo $Number) -match $REGEX) -replace "Radio on interface: A     Address: ",""

$REGEX2 = "(\bclient model: )(.*)"

$ClientModel = ((cinfo $Number) -match $REGEX2) -replace "client model: ", ""

IF ($IPAddressX -match $REGEX) {
    $State = "Active"
} ELSE {
    $State = "Inactive"
}

$Properties = @{'NodeNumbers'  =   $Number;
                'NodeType'     =   $NodeType[$NodeNumbers.IndexOf($Number)];
                'IPAddress:'   =   $IPAddressX;
                'State'        =   $State;
                'Client model' =   $ClientModel;}#END $Properties

$Output += New-Object -TypeName psobject -Property $Properties 

}#END ForEach ($Number in $NodeNumbers)

Write-Output "************************"
Write-Output "* Register Node Status *"
Write-Output "************************"


Write-Output $Output

}#END Process

END {}

}#END Function Get-NodeNumbers
