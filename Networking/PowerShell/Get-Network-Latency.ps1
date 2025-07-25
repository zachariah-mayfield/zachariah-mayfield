

Function Get-NetworkLatency {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    #[ValidateNotNullOrEmpty()]
    [String[]]$ComputerName = $Env:COMPUTERNAME
    )
    Process{
        ForEach ($Computer in $ComputerName){
            IF ($pscmdlet.ShouldProcess("This is using the `"Test-Connection`" Function against ComputerName: $Computer to determine the Ping Response")) {
                Try {
                    Test-Connection -ComputerName $Computer -count 1 -ErrorAction Stop |
                    Select IPv4Address,ReplySize,ResponseTime | Format-Table
                }# END Try #1
                Catch {
                    Write-Warning -Message "Unable to connect to Computer: $Computer"
                }# END Catch #1
            }# END IF 1
        }# END ForEach #1
     ForEach ($Computer in $ComputerName){
            IF ($pscmdlet.ShouldProcess("This is using the `"Test-Connection`" Function against ComputerName: $Computer to determine if the Response time is greater than 1000 MS of Ping")) {
                Try {
                    Test-Connection $Computer -Count 1 -ErrorAction Stop | 
                    Select IPv4Address,ResponseTime | 
                    Where-Object {$_.ResponseTime -lt 1000}
                }#END Try #2
                Catch {
                    Write-Warning -Message "Unable to connect to Computer: $Computer"
                }#END Catch #2
            }#END IF #2
            }#END ForEach #2
    }# END Process
}# END Function Get-NetworkLatency
