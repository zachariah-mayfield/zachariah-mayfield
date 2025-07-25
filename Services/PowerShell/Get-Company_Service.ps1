

CLS


Function Get-Company_Service {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(ParameterSetName="Service")]
    [ValidateSet("Apache2", "Apache-store", "CompanyCloudOrderProcessor", "CompanyConfigDataImporter", "CompanyLiveCommunicationSvc", "CompanyLiveContestSvc", "CompanyMarshallServices", 
    "CompanyTimePunchReplicationService", "CompanyWatchDogService", "CmcAgent", "CmcSvcWatcher", "DiagMan", "EPSStartup", "MSSQL`$MX", "MSSQLSERVER", 
    "MXLIVELINK", "Netlogon", "RPOSLinkServer", "SamSs", "Seriallink", "SMServer", "SNAsyncServices","SNBackupProcessor", "SNPaymentProcessor", 
    "SNRealTimeExporter", "SNTaxProcessor", "SpinUp", "SSAsyncCreditProcessor", "SSAsyncProcessor", "SSExternalOrderProcessor", "SSInstallManager",
    "SSMessageManager", "TeleQ")]
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

    $X = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | Where {$_.Name -eq $S})

    TRY {
    IF ($S -eq "EPSStartup" -and $X.Status -notmatch "Running") {
        Write-Host -ForegroundColor Yellow "#########################################################################"
        Stop-Process -Name EPS_Startup -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose -ErrorVariable "StopEPS"
        Restart-Service -InputObject $X.Name -Force -ErrorAction SilentlyContinue -Verbose -ErrorVariable "StartEPS"
    }
    ELSE {
        IF ($X.Status -match "Running"){
            Write-Host -ForegroundColor Green "Service:" '"'$X.Name'"' "Start Type is set to:" '"'$X.StartType'"' "and status is:" '"'$X.Status'"'
        }
        ELSE {
            Write-Host -ForegroundColor Yellow "Service:" '"'$X.Name'"' "Start Type is set to:" '"'$X.StartType'"' "and status is:" '"'$X.Status'"'
    
            IF ($X.StartType -match "Disabled") {
                Write-Host -ForegroundColor Cyan "Service:" '"'$X.Name'"' "Start Type is set to:" '"'$X.StartType'"' "and status is:" '"'$X.Status'"'
                # Break out of code
            }
            ELSEIF ($X.StartType -match "Automatic" -or $X.StartType -match "Manual") {
                # Write-Host -ForegroundColor Cyan "Service:" '"'$X.Name'"' "Start Type is set to:" '"'$X.StartType'"' "and status is:" '"'$X.Status'"'
                $DependentServices = ($X | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue).ServicesDependedOn.Name

                Foreach ($Z in $DependentServices) {
        
                    $Z = (Get-Service -InputObject $Z | Select -Property Name,Status,StartType)

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
                    Start-Service -InputObject $X.Name -Verbose -ErrorAction Stop
                    $Y = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | Where {$_.Name -eq $S})
                    Write-Host -ForegroundColor Green "Service:" '"'$Y.Name'"' "Start Type is set to:" '"'$Y.StartType'"' "and status is:" '"'$Y.Status'"'
                }
                Catch {
                    Write-Host -ForegroundColor Red "There was an error attempting to start the service:" $X.Name
                }
            }#END ELSEIF ($X.StartType -match "Automatic")
        }
    }
    }
    CATCH {
        Write-Host -ForegroundColor Red "There was an error with the service:" $X.Name
        $StopEPS
        $StartEPS
    } 
}#END ForEach ($S in $Service)

######################################################################################################
######################################################################################################

}# END Proccess
END {}
}# END Function Get-Company_Service
