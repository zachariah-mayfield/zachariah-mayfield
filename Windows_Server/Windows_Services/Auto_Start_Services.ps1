
$Service_Name = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | where {$_.Name -eq "Service_Name"})
IF ($Service_Name.StartType -notlike "Auto*"){

        $Service_Name | Set-Service -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service is now set to auto start"

}#END IF ($X.StartType -notlike "Auto*")
ELSE {
     Write-Host -ForegroundColor Green $Service_Name.Name "service is already set to automatic startup type"
}# END ELSE
IF ($Service_Name.Status -ne "Started"){

        $DependentServices = $Service_Name | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
            Set-Service -InputObject $A.ServicesDependedOn.name -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
            Start-Service -InputObject $A.ServicesDependedOn.name -Verbose -ErrorAction SilentlyContinue
            }
            Catch{
            Write-Host -ForegroundColor Green "No dependant services found for $A"
            }
        }
        $Service_Name | Start-Service -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service $A started Successfully"

}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $Service_Name.Name "service is already running"
}


$Service_NameUPDATER = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | where {$_.Name -eq "Service_NameUPDATER"})
IF ($Service_NameUPDATER.StartType -notlike "Auto*"){

        $Service_NameUPDATER | Set-Service -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_NameUPDATER.Name "service is now set to auto start"

}#END IF ($X.StartType -notlike "Auto*")
ELSE {
     Write-Host -ForegroundColor Green $Service_NameUPDATER.Name "service is already set to automatic startup type"
}# END ELSE
IF ($Service_NameUPDATER.Status -ne "Started"){

        $DependentServices = $Service_NameUPDATER | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
            Set-Service -InputObject $A.ServicesDependedOn.name -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
            Start-Service -InputObject $A.ServicesDependedOn.name -Verbose -ErrorAction SilentlyContinue
            }
            Catch{
            Write-Host -ForegroundColor Green "No dependant services found for $A"
            }
        }
        $Service_NameUPDATER | Start-Service -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_NameUPDATER.Name "service $A started Successfully"

}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $Service_NameUPDATER.Name "service is already running"
}


$Service_Name = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | where {$_.Name -eq "Service_Name"})
IF ($Service_Name.StartType -notlike "Auto*"){

        $Service_Name | Set-Service -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service is now set to auto start"

}#END IF ($X.StartType -notlike "Auto*")
ELSE {
     Write-Host -ForegroundColor Green $Service_Name.Name "service is already set to automatic startup type"
}# END ELSE
IF ($Service_Name.Status -ne "Started"){

        $DependentServices = $Service_Name | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
            Set-Service -InputObject $Service_Name.ServicesDependedOn.name -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
            Start-Service -InputObject $Service_Name.ServicesDependedOn.name -Verbose -ErrorAction SilentlyContinue
            }
            Catch{
            Write-Host -ForegroundColor Green "No dependant services found for $A"
            }
        }
        $Service_Name | Start-Service -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service $A started Successfully"

}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $Service_Name.Name "service is already running"
}


$Service_Name = (Get-Service | Select -Property Name,Status,StartType,ServicesDependedOn | where {$_.Name -eq "Service_Name"})
IF ($Service_Name.StartType -notlike "Auto*"){

        $Service_Name | Set-Service -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service is now set to auto start"

}#END IF ($X.StartType -notlike "Auto*")
ELSE {
     Write-Host -ForegroundColor Green $Service_Name.Name "service is already set to automatic startup type"
}# END ELSE
IF ($Service_Name.Status -ne "Started"){

        $DependentServices = $Service_Name | Select -Property ServicesDependedOn -ErrorAction SilentlyContinue
        Foreach ($A in $DependentServices) {
            TRY{
            Set-Service -InputObject $A.ServicesDependedOn.name -StartupType Automatic -Verbose -ErrorAction SilentlyContinue
            Start-Service -InputObject $A.ServicesDependedOn.name -Verbose -ErrorAction SilentlyContinue
            }
            Catch{
            Write-Host -ForegroundColor Green "No dependant services found for $A"
            }
        }
        $Service_Name | Start-Service -Verbose -ErrorAction SilentlyContinue
        Write-Host -ForegroundColor Yellow $Service_Name.Name "service $A started Successfully"

}#END ElseIF ($X.Status -ne "Started")
ELSE {
    Write-Host -ForegroundColor Green $Service_Name.Name "service is already running"
}

Start-Sleep -s 600


$X = Get-ChildItem "C:\Program Files\xx" | Where {$_.Name -ne "Archive"}
$X.count
$X.Name
$X | Get-Date



$Z = (Get-ChildItem "C:\Program Files\xx\Logs" | Select-String -Pattern "error").count

Write-Output "There are $Z errors in the trace.log file"


