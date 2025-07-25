CLS



Function Get-RogueDevice {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$PingTarget=""
)
Begin{}#END BEGIN

Process{

$PingResults = Ping $PingTarget

If ($PingResults -like "*Request timed out*" -or $PingTarget -like "*Destination host unreachable*") {
        Write-Host -ForegroundColor Yellow "ERROR Request timed out or Destination host unreachable"
        Write-host -ForegroundColor Yellow "The Rogue Device is NOT Reachable by ping!"
        $PingResults
        Write-Host -ForegroundColor Cyan  "Now running nmap"
        #cmd.exe /c "nmap -p 1-65535 -sV -sS -T5 $PingTarget"
} Else {
        Write-host -ForegroundColor Cyan "The Rogue Device is still Reachable by ping!"
        $PingResults
        Write-Host -ForegroundColor Cyan  "Now running nmap"
        #cmd.exe /c "nmap -p 1-8100 -sV -sS -T5 -Pn $PingTarget"
        }
}#END Process
END {}#END END
}#END Function Get-RogueDevice