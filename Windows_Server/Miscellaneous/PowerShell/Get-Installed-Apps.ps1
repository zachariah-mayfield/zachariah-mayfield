function Get-InstalledApps {
param()
    begin{}
    process{
        $apps = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select DisplayName, 
                DisplayVersion, 
                UnInstallString,
                InstallDate,
                @{Name="VERSION_MAJOR";Expression={($_.DisplayVersion.Split("."))[0]}},
                @{Name="VERSION_MINOR";Expression={($_.DisplayVersion.Split("."))[1]}},
                @{Name="VERSION_REVISION";Expression={($_.DisplayVersion.Split("."))[2]}},
                @{Name="VERSION_BUILD";Expression={($_.DisplayVersion.Split("."))[3]}}, 
                @{Name="GUID";Expression={$_.PSChildName}},
                @{Name="AppArchitecture";Expression={"86"}}
        # If it is a 64-bit box, then also include the Wow6432Node
        if((Get-WmiObject Win32_Processor).AddressWidth -eq 64){
            $apps += Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
                     Select DisplayName,
                     DisplayVersion, 
                     UnInstallString,
                     InstallDate, 
                     @{Name="VERSION_MAJOR";Expression={($_.DisplayVersion.Split("."))[0]}},
                     @{Name="VERSION_MINOR";Expression={($_.DisplayVersion.Split("."))[1]}},
                     @{Name="VERSION_REVISION";Expression={($_.DisplayVersion.Split("."))[2]}},
                     @{Name="VERSION_BUILD";Expression={($_.DisplayVersion.Split("."))[3]}}, 
                     @{Name="GUID";Expression={$_.PSChildName}}, 
                     @{Name="AppArchitecture";Expression={"64"}}
        }

        $apps | Where{ !([string]::IsNullOrEmpty($_.DisplayName)) }
    }
    end{}
}

# Get all 32\64 bit applications
$installedApps = Get-InstalledApps
# Find any application with SLOOBAPP in the name
$silverLight = $installedApps | Where-Object {$_.DisplayName -match "SLOOBAPP"}

#If an application was found (variable not null)...
if ($silverLight) {
    foreach ($application in $installedApps) {
        #if the uninstall string is not null...
        If ($application.UninstallString){
            #Here you are specifying (x86) only, so this would fail if there were a 64-bit Silverlight installation
            #You should use similar logic I'm using in the function above to see if it's a 64-bit machine or I'm adding
            #an AppArchitecture param, so you could do if ($application.AppArchitecture -eq 32){"Set location for 32}else{Set Location for 64}
            Set-Location -Path "c:\Program Files (x86)\Microsoft Silverlight\5.1.30514.0"
            #Rather than use a manual string (e.g. $uninst, you would just reference
            "Running command: {0} from {1}" -f $application.UninstallString, (Get-Location)
            Start-Process -FilePath cmd.exe -ArgumentList '/c', $application.UninstallString -wait
        }
        else {
            "There is not uninstall string for {0}" -f $application.DisplayName
        } #if UnInstallString
    } #for each application
}
else {
    "Silverlight is not installed."
} #if $silverlight
