CLS

$LogName = "xCustomSplunkAlertsx"
$Source = "HardDisk_FreeSpace_Monitor"
$EntryType = "Warning"
$EventId = 5555
$Message = ”Disk Over Threshold: ”

Function Create-Custom_EventLog {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(Mandatory=$true)]
    [String]$LogName,
    [Parameter(Mandatory=$true)]
    [String]$Source,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Information","Warning","Error","SuccessAudit","FailureAudit")]
    [String]$EntryType,
    [Parameter(Mandatory=$true)]
    [int]$EventId,
    [Parameter(Mandatory=$true)]
    [String]$Message
    )
Begin {
    $FormatEnumerationLimit="0"
    New-EventLog -LogName $LogName -Source $Source -ErrorAction SilentlyContinue
}
Process {
    $Message = [Ordered]@{}
    
    $Message.add( "DiskOverThreshold", (”Disk Over Threshold: ” + [String]($Disk_Over_Threshold)))
    $Message.add( " BlankLine1",("
"))
    
}
END{
    Write-EventLog -LogName $LogName -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message.Values
}
}#END Function

Create-Custom_EventLog -LogName $LogName -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message
