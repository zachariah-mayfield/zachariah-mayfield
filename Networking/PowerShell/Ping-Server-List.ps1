CLS

$CSV_Path = "C:\Server_Names_List.csv"

Function Ping-ServerList {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [System.IO.FileInfo]$CSV_Path
    )
    Begin{
        $FormatEnumerationLimit="0"
        $CSV_Data = Import-Csv -Path $CSV_Path
        $CSVRowNumber = $CSV_Data.count
        $Values = @(0..$CSVRowNumber)
    }
    Process {
        ForEach ($V in $Values) {
            IF ($CSV_Data[$v] -ne $null) {
                $ServerName = $CSV_Data[$V].ServerNames
                #$MySession = New-PSSession -ComputerName $ServerName
                #Invoke-Command -Session $MySession -ScriptBlock {
                    Test-Connection -ComputerName $ServerName
                #}# End Invoke-Command
            }# END IF ($CSV_Data[$v] -ne $null)
        }# END ForEach ($V in $Values)
    }# END Process
    End {Get-PSSession | Remove-PSSession }# END END
}# END Function 

Ping-ServerList -CSV_Path $CSV_Path
