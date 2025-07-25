

Function Get-HardDiskUtilization {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    #[ValidateNotNullOrEmpty()]
    [String[]]$ComputerName = $Env:COMPUTERNAME
    )
    Process{
        ForEach ($Computer in $ComputerName){
            $Culture = New-Object System.Globalization.CultureInfo -ArgumentList "en-us",$false
            $Culture.NumberFormat.PercentDecimalDigits = 4
            $Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $Computer
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -MemberType Noteproperty -Name 'Computer Name:' -Value ($Computer)
            $Obj | Add-Member -MemberType NoteProperty -Name 'Total System Space(GB):' -Value ($Disk.size/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space(GB):' -Value ($Disk.FreeSpace/1GB).ToString("N4")
            $Obj | Add-Member -MemberType NoteProperty -Name 'System Free Space Percentage(GB):' -Value (($Disk.FreeSpace/$Disk.Size).ToString("P", $Culture))
            
            IF ($obj.'System Free Space Percentage(GB):' -lt "5") {
            $obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold GT 5% :' -Value $True
            } Else {
            $obj | Add-Member -MemberType NoteProperty -Name 'Free Space Threshold LT 5% :' -Value $False
            }
                    
            $obj | Format-List
        }
    }
}# END of Function Get-HardDiskUtilization
