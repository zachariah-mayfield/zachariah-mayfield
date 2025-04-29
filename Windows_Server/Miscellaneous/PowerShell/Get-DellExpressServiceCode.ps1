Function Get-DellExpressServiceCode{

param(
    [Parameter(Mandatory=$False, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage="A Dell Service Tag (e.g., ABC1234).")][System.String]$ServiceTag=(Get-WmiObject Win32_Bios).SerialNumber,
    [switch]$SkipSystemCheck
)

    Begin{
        If($ServiceTag.Count > 1) {$SkipSystemCheck = $True}
    }

    Process{

        If([System.String]::IsNullOrEmpty($ServiceTag)) { Throw [System.Exception] "Could not retrieve system serial number." }

        If(-not $SkipSystemCheck){
            If((Get-WmiObject Win32_ComputerSystem).Manufacturer.ToLower() -notlike "*dell*") { Throw [System.Exception] "Dude, you don't have a Dell: $((Get-WmiObject Win32_ComputerSystem).Manufacturer)" }
        }

        $Alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        $ca = $ServiceTag.ToUpper().ToCharArray()
        [System.Array]::Reverse($ca)
        [System.Int64]$ExpressServiceCode=0

        $i=0
        foreach($c in $ca){
            $ExpressServiceCode += $Alphabet.IndexOf($c) * [System.Int64][System.Math]::Pow(36,$i)
            $i+=1
        }

        $ExpressServiceCode
    }

    End{}

} Get-DellExpressServiceCode