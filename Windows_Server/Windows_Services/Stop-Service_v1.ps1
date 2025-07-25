

Function XXX-EmergencyStop {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    #[ValidateNotNullOrEmpty()]
    [String[]]$ComputerName = $Env:COMPUTERNAME,

    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
    [Switch]$STOP,
    
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
    [Switch]$PSR_STATUS
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

ForEach ($Computer in $ComputerName){

  $A = (Get-Process -IncludeUserName * | Where-Object {$_.username -match "XXX_Service" <#-and $_.Name -notmatch "XXX" -and $_.Name -notmatch "XXX"#>})

IF ($A.Responding -eq "True") {
    "$A " + "Process is currently running under the username: XXX_Service"
} Else {
    "$A" + "No Processes are currently running under the username: XXX_Service"
}# End If $Z.Status
IF ($STOP){
    $A  | Stop-Process -Force -Verbose
    Write-Output "$A" + " Process is stoping"

}# END IF $STOP
}# END ForEach ($Computer in $ComputerName) #1
}# END Proccess
END {}
}# END Function XXX-EmergencyStop
