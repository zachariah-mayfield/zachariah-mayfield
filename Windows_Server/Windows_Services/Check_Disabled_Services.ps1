Clear-Host

$Service = "XXXXXXXXXXXXXXXXXX"

$SetAuto = $true

$START = $true

ForEach ($S in $Service) {

    $X = (Get-Service | Select-Property Name, Status, StartType, ServicesDependedOn | Where-Object {$_.Name -eq $S})

    IF ($X.StartType -match "Disabled"){
        Write-Host -ForegroundColor Yellow $X.name "is Disabled"
    } 
    ELSE {
        Write-Host -ForegroundColor Green $X.name "Start Type is" $X.StartType
    }

}
