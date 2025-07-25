
param(
    [Parameter(Mandatory = $true)] [string[]] $Mailbox = "",
    [Parameter(Mandatory = $true)] [string] $OutputPath = "",
    [Parameter(Mandatory = $false)] [int] $Interval = 15,
    [Parameter(Mandatory = $false)] [boolean] $OnPremise = $True,
    [Parameter(Mandatory = $false)] [boolean] $InCloud = $False
)

function GetCheck-FolderPath {
    # Verify the folder path entered
    if ($OutputPath.Length -lt 2) { Write-Host "An invalid path was entered." -ForegroundColor White -BackgroundColor Red
        GetCheck-FolderPath
    }
    if ($OutputPath.EndsWith('\') -ne $true) { 
        $OutputPath = $OutputPath+'\'
    }
    try { 
        $temp = Get-Item $OutputPath -ErrorAction Stop
    }
    catch { 
        Write-Host "The path entered does not exist." -ForegroundColor White -BackgroundColor Red
        exit
    }
	$temp = $null
    return $OutputPath
}

function Connect-ToTheCloud {
    # Create the remote PowerShell session
    $psURL = "https://ps.outlook.com/powershell"
    Write-Host "Creating PowerShell session with Exchange Online..." -ForegroundColor Yellow
    $cred = Get-Credential
    $sessionOptions = New-PSSessionOption -IdleTimeoutMSec $idleTimeout
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $psURL -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $session -AllowClobber
}

function Get-ExchangeVersion {
    # Check Exchange version for later cmdlets
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup\")) {
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup\").MsiProductMajor -eq 15) {
            $version = "15"
            return $version
        }
    }
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\Setup\")) {
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\Setup\").MsiProductMajor -eq 14) {
            $version = "14"
            return $version
        }
    }
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Exchange\v8.0\Setup\")) {
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Exchange\v8.0\Setup\").MsiProductMajor -eq 8) {
            $version = "12"
            return $version
        }
    }
}

Clear-Host
Write-Host "Do not close this window until you are ready to collect the logs." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Press any key to continue ..." -ForegroundColor Yellow
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host

# Check to ensure the outputPath is valid
$OutputPath = GetCheck-FolderPath

# Convert the interval into seconds
$Interval = $Interval*60
$idleTimeout = $Interval*1001

# Determine if the mailbox is in the cloud or on-premise
if($InCloud -eq $True) {
    Connect-ToTheCloud
}
else {
    $version = Get-ExchangeVersion
    #Add-PSSnapin microsoft.exchange.management.powershell.e2010
    $isOnPrem = $true
}

# Build array of mailbox(es) to retrieve logs from
$targetMailboxes = @()
foreach($m in $mailbox) {
	if($m.Length -gt 1) {
		$targetMailboxes += $m
	}
}

# Looping indefinitely...
while(1) {
    # Ensure that mailbox logging is not disabled after 72 hours
    # For each mailbox...
    foreach($targetMailbox in $targetMailboxes) {
     #...attempt to enable mailbox logging for the mailbox
        Write-Host "Enabling mailbox log for $targetMailbox." -ForegroundColor DarkGray
Sleep 5
        try { 
            Set-CasMailbox $targetMailbox -ActiveSyncDebugLogging:$true -ErrorAction Stop -WarningAction SilentlyContinue }
        catch { 
            # Should only error when mailbox is on a different version of Exchange than server where command executed
            Write-Host "Error enabling the ActiveSync mailbox log for $targetMailbox. This script must run on the version of Exchange where the mailbox is located." -ForegroundColor White -BackgroundColor Red
            exit
        }
    }    
    # For each target mailbox...
    foreach($targetMailbox in $targetMailboxes)
    {
        Write-Host "Getting all devices for mailbox:" $targetMailbox
        # ...get all devices syncing with mailbox...
        if ($isOnPrem -ne $true -or $version -eq "15") {
            try { $devices = Get-MobileDeviceStatistics -Mailbox $targetMailbox }
            catch { Write-Host "Error locating devices for $targetMailbox." -ForegroundColor White -BackgroundColor Red }
        }
        else {
            try { $devices = Get-ActiveSyncDeviceStatistics -Mailbox $targetMailbox }
            catch { Write-Host "Error locating devices for $targetMailbox." -ForegroundColor Red }
        }
        
        #...and for each device...
    	if ($devices -ne $null) {
            foreach($device in $devices)
            {
                Write-Host "Downloading logs for device: " $device.DeviceFriendlyName $device.DeviceID -ForegroundColor Cyan

                # ...create an output file...
                $fileName = $OutputPath + $targetMailbox + "_MailboxLog_" + $device.DeviceFriendlyName + "_" + $device.DeviceID + "_" + (Get-Date).Ticks + ".txt"
                
                # ...and write the mailbox log to the output file...
                if ($isOnPrem -ne $true -or $version -eq "15") {
                    try { Get-MobileDeviceStatistics $device.Identity -GetMailboxLog -ErrorAction SilentlyContinue | select -ExpandProperty MailboxLogReport | Out-File -FilePath $fileName }
                    catch { Write-Host "Unable to retrieve mailbox log for $device.Identity" -ForegroundColor White -BackgroundColor Red }
                }
                if ($isOnPrem -eq $true -and $version -eq "14") {
                    try { Get-ActiveSyncDeviceStatistics $device.Identity -GetMailboxLog:$true -ErrorAction SilentlyContinue | select -ExpandProperty MailboxLogReport | Out-File -FilePath $fileName }
                    catch { Write-Host "Unable to retrieve mailbox log for $device" -ForegroundColor Yellow }
                }
                if($isOnPrem -eq $true -and $version -eq "12") { 
                    try {Get-ActiveSyncDeviceStatistics $device.Identity -GetMailboxLog:$true -ErrorAction SilentlyContinue -OutputPath $OutputPath }
                    catch { Write-Host "Unable to retrieve mailbox log for $device" -ForegroundColor Yellow }
                }
            }
        }
        # Escape the infinite loop if there are no devices
        else { Write-Host "No devices found for $targetMailbox." -ForegroundColor Yellow }
    }

    #...and then wait x number of seconds before retrieving the logs again
    Write-Host "Reminder: Do no close this window until you are ready to collect the logs." -ForegroundColor White -BackgroundColor Red
    Write-Host "Next set of logs will be retrieved at" (Get-Date).AddSeconds($Interval) -ForegroundColor Green
    Start-Sleep $Interval
}
