cls
# Windows 7
Function Get-DNSResults {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [string]$DNSName = "www.Company.com"
    )

Begin{
    $Global:FormatEnumerationLimit=-1
}

Process {
    
    $StoreNumber = ([System.Environment]::MachineName).subString(2,5)

    $CheckDNS = [System.Net.DNS]::GetHostEntry($DNSName)  | Select AddressList

    IF ($CheckDNS.AddressList -match "1.1.1.1") {
       #Write-Host -ForegroundColor Cyan $DNSName "resolves to the correct IPAddress:" $CheckDNS.AddressList
        $DNSState = "Resolved"
    }
    ELSE {
        Write-Host -ForegroundColor Cyan $DNSName "resolves to an incorrect IPAddress:" $CheckDNS.AddressList
        $DNSState = "NOT-Resolved"
    }


    $Properties = @{'Location Number'  =   $StoreNumber;
                    'DNS Name'         =   $DNSName;
                    'DNS IPAddress:'   =   $CheckDNS.AddressList;
                    'DNS State'        =   $DNSState;}#END $Properties

    IF ($DNSState -eq "NOT-Resolved") {
    
        $Output += New-Object -TypeName psobject -Property $Properties

        Write-Output $Output | Format-Table -AutoSize 
    }

       
}

End {}
}#END Function Get-DNSResults


################
# Windows 10
Function Get-DNSResults {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [string]$DNSName = "www.Company.com"
    )

Begin{
    $Global:FormatEnumerationLimit=-1
}

Process {

    $CheckDNS = Resolve-DnsName -Name $DNSName | Select IPAddress

    IF ($CheckDNS -match "1.1.1.1") {
        Write-Host -ForegroundColor Cyan $DNSName "resolves to the correct IPAddress:" $CheckDNS.IPAddress
    }
    ELSE {
        Write-Host -ForegroundColor Cyan $DNSName "resolves to an incorrect IPAddress:" $CheckDNS.IPAddress
    }
}

End {}
}#END Function Get-DNSResults



