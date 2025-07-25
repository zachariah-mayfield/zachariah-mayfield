
Function Restart-Service {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ParameterSetName="Service")]
    [ValidateSet("Apache2", "Apache-store", "Netlogon")]
    [String[]]$Service
 )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {
######################################################################################################
######################################################################################################

ForEach ($S in $Service) {

    $X = (Get-Service | Select-Property Name,Status,StartType,ServicesDependedOn | Where {$_.Name -eq $S})

    Write-Host -ForegroundColor Cyan "Service:" '"'$X.Name'"' "Start Type is set to:" '"'$X.StartType'"' "and status is:" '"'$X.Status'"'
    $DependentServices = ($X | Select-Property ServicesDependedOn -ErrorAction SilentlyContinue).ServicesDependedOn.Name

    Foreach ($Z in $DependentServices) {
        
        $Z = (Get-Service -InputObject $Z | Select-Property Name,Status,StartType)

        IF ($Z.StartType -match "Disabled") {
            Write-Host -ForegroundColor Cyan "Service:" '"'$Z.Name'"' "Start Type is set to:" '"'$Z.StartType'"' "and status is:" '"'$Z.Status'"'
            TRY {
                Set-Service -InputObject $Z.Name -Verbose -StartupType Automatic -ErrorAction Stop 
                #Start-Service -InputObject $Z.Name -Verbose -ErrorAction Stop
            }
            CATCH {
                Write-Host -ForegroundColor Red "There was an error attempting to change the start type of the service:" $Z.Name
            }
        }
        ELSEIF ($Z.StartType -match "Boot" -or $Z.StartType -match "System"){
            Write-Host -ForegroundColor Yellow "Service:" '"'$Z.Name'"' "Start Type is set to:" '"'$Z.StartType'"' "and status is:" '"'$Z.Status'"'
        } ELSE {
            Write-Host -ForegroundColor Green "Service:" '"'$Z.Name'"' "Start Type is set to:" '"'$Z.StartType'"' "and status is:" '"'$Z.Status'"'
        }
    }
    TRY {
        Set-Service -InputObject $X.Name -Verbose -StartupType Automatic -ErrorAction Stop
        Restart-Service -InputObject $X.Name -Verbose -ErrorAction Stop -Force
        Write-Output "The service" $X.Name "has started up successfully"
    }
    Catch {
        Write-Host -ForegroundColor Red "There was an error attempting to start the service:" $X.Name
    }
}#END ForEach ($S in $Service)



}# END Proccess
END {}
}# END Function Restart-Service
