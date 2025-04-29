CLS

Function Start-HealthCheck {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process{

Set-Location -Path "C:\Folder"

$StartDate = (Get-Date -UFormat "%m/%d/%Y")

$EndDate = $(Get-Date).AddDays(1).ToString("MM/dd/yyyy")

$SearchWord1 = (“*String*”)

$OutputFile1 = “C:\Folder\Test1.TXT”

$WarningSearch = (cmd /c "logsearch $StartDate $EndDate $SearchWord1 ""$OutputFile1""")

$SearchWord2 = (“*Error*”)

$OutputFile2 = “C:\Folder\Test2.TXT”

$ErrorSearch = (cmd /c "logsearch $StartDate $EndDate $SearchWord2 ""$OutputFile2""")

IF ($WarningSearch) {
    Write-Output ("This is the Search results for the word: $SearchWord1")
    Write-Output ("")
    Get-Content -Path $OutputFile1
    Write-Output ("")
}
ELSE {
    Write-Output ("")
    Write-Output ("There were no results in the search for the word: $SearchWord1")
    Write-Output ("")
}

IF ($WarningSearch) {
    Write-Output ("This is the Search results for the word: $SearchWord2")
    Write-Output ("")
    Get-Content -Path $OutputFile2
    Write-Output ("")
}
ELSE {
    Write-Output ("")
    Write-Output ("There were no results in the search for the word: $SearchWord2")
    Write-Output ("")
}

}#END Process
END {}#END END
}# END Function Start-HealthCheck

