# Get-Service

IF ($MainService.StartType -eq "disabled") {
    # Break out of code
}

IF ($MainService.StartType -eq "automatic") {
    $DependantService = Get-Service $MainService.ServicesDependedOn.Name
}
    
IF ($DependantService.StartType -eq "disabled") {
    # Change Dependant Service start up type to automatic
    # Start up Main Service
}

# Restart-Service

IF ($MainService.StartType -eq "disabled") {
    # Change Main Service start up type to automatic
    # Start up Main Service
}

IF ($MainService.StartType -eq "automatic") {
    $DependantService = Get-Service $MainService.ServicesDependedOn.Name
}
    
IF ($DependantService.StartType -eq "disabled") {
    # Change Dependant Service start up type to automatic
    # Start up Main Service
}