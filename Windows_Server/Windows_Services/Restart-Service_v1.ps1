
Function Restart-Service {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()] 
    [Switch]$START,
    [Parameter()] 
    [Switch]$ReSTART,
    [Parameter()] 
    [Switch]$SetAuto,
    
    [Parameter(ParameterSetName="Service")]
    [ValidateSet("XXXProcessor")]
    [String[]]$Service
 )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {
######################################################################################################
######################################################################################################

$X = (Get-Service | Select-Property Name,Status,StartType,ServicesDependedOn | Where-Object {$_.Name -eq $Service})
IF ($X.StartType -notlike "Auto*"){
    Write-Host -ForegroundColor Yellow $X.Name "service is in a Disabled startup type state."
    #Added a Break to jump to the end *we will remove this later once we make the switch to auto start the services.
    IF ($SetAuto){
        Try {
        $X | Set-Service -StartupType Automatic -Verbose -ErrorAction Stop
        Write-Host -ForegroundColor Green $X.Name "service startup type is now set to Automatic"
        }
        Catch {
        Write-Host -ForegroundColor Yellow $X.Name "service failed to change the startup type to: auto start"
        }
    }#END IF ($SetAuto)
}#END IF ($X.StartType -notlike "Auto*")
ELSE {
     Write-Host -ForegroundColor Green $X.Name "service is already set to automatic startup type"
}# END ELSE
IF ($X.Status -ne "Started"){
    IF ($START){
        $DependentServices = $X | Select-Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
                $Depend = $DependentServices.ServicesDependedOn.Name
                Foreach ($Z in $Depend){
                    Set-Service -InputObject $Z -StartupType Automatic -Verbose 
                }#END Foreach ($Z in $Depend)
                Start-Service $A.ServicesDependedOn.Name -Verbose
                }#END TRY
                Catch{
                Write-Host -ForegroundColor Green "No dependant services found for" $X.Name
                }#END Catch
                }#END Foreach ($A in $DependentServices)
        TRY {
        $X | Start-Service -Verbose -ErrorAction Stop
        }
        Catch {
        Write-Host -ForegroundColor Yellow "There was an error attepting to start the service:" $X.Name
        }
}# END IF ($START)
}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $X.Name "service is already running"
}

######################################################################################################
######################################################################################################
IF ($ReSTART){
        $DependentServices = $X | Select-Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
                $Depend = $DependentServices.ServicesDependedOn.Name
                Foreach ($Z in $Depend){
                    Set-Service -InputObject $Z -StartupType Automatic -Verbose 
                }#END Foreach ($Z in $Depend)
                Start-Service $A.ServicesDependedOn.Name -Verbose
                }#END TRY
                Catch{
                Write-Host -ForegroundColor Green "No dependant services found for" $X.Name
                }#END Catch
                }#END Foreach ($A in $DependentServices)
        TRY {
        $X | Restart-Service -Verbose -ErrorAction Stop
        Write-Host -ForegroundColor Green "service:" $X.Name "started successfully"
        }
        Catch {
        Write-Host -ForegroundColor Yellow "There was an error attepting to start the service:" $X.Name
        }

    }

}


}# END 