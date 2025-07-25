

Function Test-URL {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$URL=""
    )
Begin{}#END BEGIN
Process{
    Try{
    $CheckWebSite = Invoke-WebRequest $URL -ErrorAction Stop
    IF ($CheckWebSite -eq $null) {
        Write-Host -ForegroundColor Red "$URL site does not respond."
    }
    ELSEIF ($CheckWebSite.StatusCode -eq "200" -and $CheckWebSite.StatusDescription -eq "OK") {
        Write-Host -ForegroundColor Yellow "$URL site successfully responds to ping and loads successfully”
    }#END ELSEIF
    }
    Catch {
        Write-Host -ForegroundColor Red "$URL could not be resolved at this time."
    }
}#END Process
END {}#END END
}# END Function Test-URL
