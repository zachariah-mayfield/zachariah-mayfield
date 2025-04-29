CLS

function Get-InstalledApps {
param()
    begin{}
    process{
        $apps = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select DisplayName, 
                DisplayVersion, 
                UnInstallString,
                InstallDate,
                InstallLocation,
                @{Name="VERSION_MAJOR";Expression={($_.DisplayVersion.Split("."))[0]}},
                @{Name="VERSION_MINOR";Expression={($_.DisplayVersion.Split("."))[1]}},
                @{Name="VERSION_REVISION";Expression={($_.DisplayVersion.Split("."))[2]}},
                @{Name="VERSION_BUILD";Expression={($_.DisplayVersion.Split("."))[3]}}, 
                @{Name="GUID";Expression={$_.PSChildName}},
                @{Name="AppArchitecture";Expression={"86"}}
        $apps | Where{ !([string]::IsNullOrEmpty($_.DisplayName)) }
    }
    end{}
}

# Get all 32 bit applications
$installedApps = Get-InstalledApps
# Find any application with java in the name
$Applications = $installedApps | Where-Object {$_.DisplayName -like "*yahoo*"}
#If an application was found (variable not null)...
if ($Java) {
    foreach ($Application in $Applications) {
        #If the uninstall string is not null...
        If ($Application.UninstallString){
            $pathX = "C:\Program Files\Yahoo!\yset\{74D0847B-6807-9F4C-A5F1-B76BBA17ED4F}\"
            $BadApp = "C:\Program Files\Yahoo!\yset\{74D0847B-6807-9F4C-A5F1-B76BBA17ED4F}\unset.exe"
            Set-Location -Path "$pathX"
            #Rather than use a manual string (e.g. $uninst, you would just reference
            "Running command: {0} from {1}" -f $application.UninstallString, (Get-Location)
             Start-Process CMD.EXE /C “$BadApp” -uninstall
        } else {
            "There is not a uninstall string for {0}" -f $Java.DisplayName
        } #If UnInstallString for $Java 
        } #for each $Application in $Applications
        } else {
            write-host The app you were searching for is not installed.
} #if $Java

# start /wait msiexec.exe /x {f0b430d1-b6aa-473d-9b06-aa3dd01fd0b8} /qn
# C:\Program Files\Yahoo!\yset\{74D0847B-6807-9F4C-A5F1-B76BBA17ED4F}\unset.exe
# "C:\Program Files\Yahoo!\Common\unyt.exe" /S

$CMDCOMMAND = @("C:\Program Files\Yahoo!\yset\{74D0847B-6807-9F4C-A5F1-B76BBA17ED4F}\unset.exe")
Start-Process '"$CMDCOMMAND" /s'
