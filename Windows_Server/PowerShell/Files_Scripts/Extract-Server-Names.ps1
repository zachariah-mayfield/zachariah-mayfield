CLS

$FormatEnumerationLimit="0"

$RegEX = ('(^New\Session\s\W\s[[])([a-zA-Z0-9]{3,4}[-][a-zA-Z0-9]{3,}[-]?[a-zA-Z0-9]+)(]\s)')

$Content = ((Get-Content -Path "C:\temp\ErrorLogFile.txt"))

$Results = $Content | Select-String $RegEX -AllMatches

$All_Matches = $Results.Matches

ForEach ($Match in $All_Matches) {
    $Value = $Match.Groups[2].Value
    $Value
}
