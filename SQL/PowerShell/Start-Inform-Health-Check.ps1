CLS

Function Start-InformHealthCheck {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = "SilentlyContinue"
### Added by Eric Turpin to expose invoke-sqlcmd cmdlet
Import-Module sqlps -cmdlet Invoke-Sqlcmd
Get-Command invoke-sqlcmd | ForEach-Object {$_.Visibility = 'Public'}
### Added by Eric Turpin to expose invoke-sqlcmd cmdlet
}#END BEGIN
Process{

IF (Test-Path "C:\Program Files (x86)") {
# This is the part that checks the log file. 
    $TraceLog = "C:\Program Files (x86)\MacromatiX\LiveLinkService\Logs\trace.log"
}
ELSE {
    $TraceLog = "C:\Program Files\MacromatiX\LiveLinkService\Logs\trace.log"
}
IF (Test-Path $TraceLog) {
    Try{
       $Last25 = (Get-Content -Path $TraceLog -Force -Tail 25 -ErrorAction SilentlyContinue)
        Write-Output ("This is the most recent 25 lines of InForm Live Link Service logs:")
        Write-Output (" ")
        Write-Output $Last25 
    }
    Catch {
        $_
    }
}
Else {
    Write-Output ("The file Trace.log, Does not exist in the path: $TraceLog")
}

Try {
    # sqlcmd to check the database size of "MXDatabaseEngine"
    # -S = Server
    # -Q = cmdline query
    # -d = db_name

    $Server = ".\mx"
    $Database = "macromatix"

    $Query = "
    exec sp_spaceused
    "
    $RunSQL = (Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Query | Format-List)
    Write-Output (" ")
    Write-Output ("This is the database size for `"MXDatabaseEngine`":")
    Write-Output ($RunSQL)
}
Catch {
    $_
}

Write-Output (" ")

IF (Test-Path "C:\Program Files (x86)") {
    $InFormXMLFIlePath = "C:\program files (x86)\radiant\lighthouse\data\exports\Companytran"
}
ELSE {
    $InFormXMLFIlePath = "C:\Program Files\radiant\lighthouse\data\exports\Companytran"
}
IF (Test-Path $InFormXMLFIlePath) {
    
    $FileCount = (Get-ChildItem $InFormXMLFIlePath | where {$_.extension -eq ".xml"} | Measure-Object ).Count

    Write-Output ("There are $FileCount InFORM Export Files in this directory: $InFormXMLFIlePath")

}

}#END Process
END {}#END END
}# END Function

Start-InformHealthCheck
