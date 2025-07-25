CLS

$File_Path = "D:\Certs\Certificates.txt"

Function Get-FileStatus {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    Param (
    [ValidateNotNullOrEmpty()]
    [System.IO.Path]$File_Path
    )
Begin {
    $Global:FormatEnumerationLimit=-1
}
Process {
    IF ((Test-Path $File_Path) -ne $true) {
        Write-Host -ForegroundColor Yellow
    }
}#END Process
END {}
}#END Function
