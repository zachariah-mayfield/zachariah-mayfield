CLS

$FilePath = "C:\temp\Log_File1.txt"
$RegEX = ('([\w?]{1,})(\=)([^;]*)')

$Content = (Get-Content -Path $FilePath)
# This will pull all of the 'LINE' Results from the $Content.
$Results = $Content | Select-String $RegEX -AllMatches
# This will pull all of the 'LINE' Results from the $Content, and show them as individual objects.
$All_Matches = $Results.Matches

$All_Matches.Value
