 Function Get-DellComputerInfo {
<#
.Synopsis 
    This function will export the computername, BIOS serial number, and the dell sepress service code. 
.Description 
    This function 
.Parameter ComputerName 
    The name of the computer  
.Parameter 
    The name of the
.Parameter password 
    The  
.Parameter description 
    The description for the
.EXAMPLE
    Get-DellComputerInfo Hostname
.Notes 
    NAME:  Get-ComputerInfo 
    AUTHOR: Zack Mayfield
    LASTEDIT: 03/28/2019 02:18:42PM 
    KEYWORDS: Computer Info 
.Link 
    
.PowerShell Version 
    2.0 Or greater Prefered...
.More Info
    
#>
    
[CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                SupportsShouldProcess=$true,
                PositionalBinding=$false,
                HelpUri = 'http://www.microsoft.com/',
                ConfirmImpact='Medium')]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [Alias('Hostname')]
        [String[]]$ComputerName
        )
        $Server=Hostname
        $Computername=$server
        
        
        $BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $Computername
        $Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $Computername
        $SystemInfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName $Computername

        $ServiceTag=(Get-WmiObject Win32_Bios).SerialNumber
        $Alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        $ca = $ServiceTag.ToUpper().ToCharArray()
        [System.Array]::Reverse($ca)
        [System.Int64]$ExpressServiceCode=0
        $i=0
        foreach($c in $ca){
            $ExpressServiceCode += $Alphabet.IndexOf($c) * [System.Int64][System.Math]::Pow(36,$i)
            $i+=1
        } 
        
        
        $Obj = New-Object -TypeName PSObject
        $Obj | Add-Member -MemberType NoteProperty -Name 'Computer Name:' -Value $Server
        $Obj | Add-Member -MemberType NoteProperty -Name "BIOS Serial #:  " -Value ($BIOS.Serialnumber)
        
        $Obj | Add-Member -MemberType NoteProperty -Name "Dell Express Service Code#:" -Value ($ExpressServiceCode)
        
    $Obj 
 
 }

Get-DellComputerInfo 