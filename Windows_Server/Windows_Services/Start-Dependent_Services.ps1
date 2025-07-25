CLS

$Service = "xxxxxxxxxxxxxxx"

$SetAuto = $true

$START = $true

ForEach ($S in $Service) {

$X = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | where {$_.Name -eq $S})

IF ($X.StartType -match "Disabled*"){
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
IF ($X.Status -ne "Running"){
    IF ($START){
        $DependentServices = ($X | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue).ServicesDependedOn.Name
        Foreach ($Z in $DependentServices) {
            TRY{
                #$Depend = $DependentServices.ServicesDependedOn.Name
                #Foreach ($Z in $Depend){

                $Z = (Get-Service -InputObject $Z | Select -Property Name,Status,StartType)

                ############## Add check here to make sure that the dependant service arent disabled.
                IF ($Z.StartType -like "Disabled" -or $Z.StartType -like "Boot" -or $Z.StartType -like "System"){
                    Write-Host -ForegroundColor Yellow "Service:" $Z.name "Start Type is:" $Z.StartType
                } ELSE {
                    Write-Host -ForegroundColor Green "Service:" $Z.name "Start Type is:" $Z.StartType
                     
                }

                    #####   Set-Service -InputObject $Z.Name -StartupType Automatic -Verbose 
                    
                
                #}#END Foreach ($Z in $Depend)
                Start-Service $Z.Name -Verbose
                }#END TRY
                Catch{
                    Write-Host -ForegroundColor Green "No dependant services found for" $X.Name
                }#END Catch
                }#END Foreach ($A in $DependentServices)
        TRY {
            $X | Start-Service -Verbose -ErrorAction Stop
            Write-Host -ForegroundColor Green "Service:" $X.Name "started successfully"
        }
        Catch {
            Write-Host -ForegroundColor Yellow "There was an error attempting to start the service:" $X.Name
        }
}# END IF ($START)
}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $X.Name "service is already running"
}

######################################################################################################
######################################################################################################
IF ($ReSTART){
        $DependentServices = $X | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue
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
            $X | Restart-Service -Verbose -ErrorAction Stop -Force
            Write-Host -ForegroundColor Green "Service:" $X.Name "started successfully"
        }
        Catch {
            Write-Host -ForegroundColor Yellow "There was an error attempting to start the service:" $X.Name
        }
}# END IF ($ReSTART)

}#END ForEach ($S in $Service)

