CLS

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
$ExpressServiceCode

