CLS


Function Restart-Router {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
Param (
[Parameter()]
    [String]$StoreNumber,
    [Parameter()]
    [String]$UserName = ("UserName"),
    [Parameter()]
    #[String]$CyberArkPassword = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password),
    [String]$Password = ("Password"),
    [Parameter()]
    [String]$NewTXTFilePath = ("C:\temp\SSH.txt"),
    [Parameter()]
    [String]$NewBatchFilePath = ("C:\temp\SSH-To-Router.BAT"),
    [Parameter()]
    [String]$TXTContent = ("execute reboot
y")    
    
)
        
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {
###########################################################################################################################################
###########################################################################################################################################

$Router = (Test-NetConnection ($StoreNumber + ".RTR")).RemoteAddress.IPAddressToString

###########################################################################################################################################
###########################################################################################################################################

$TXTContent | Out-File $NewTXTFilePath -Encoding ascii -Confirm:$false -Force

###########################################################################################################################################
###########################################################################################################################################

[String]$BatchContent = ("CLS

`"C:\Program Files\PuTTY\Plink.exe`" -ssh $UserName$Router -P 22 -pw $Password -v -m `"$NewTXTFilePath`"")

###########################################################################################################################################
###########################################################################################################################################

$BatchContent | Out-File $NewBatchFilePath -Encoding ascii -Confirm:$false -Force

###########################################################################################################################################
###########################################################################################################################################

 Write-Output ("Router Reboot is starting. . . ")
 
 Write-Output ("Router Reboot Process can take up to 5 minutes.")

###########################################################################################################################################
###########################################################################################################################################

$RunSSHCommand = Start-Process -FilePath $NewBatchFilePath -NoNewWindow

###########################################################################################################################################
###########################################################################################################################################

Sleep -Seconds 15

###########################################################################################################################################
###########################################################################################################################################

While (!(Test-Connection $Router -Quiet -Count 1)) {
    Write-Output ("Router: $Router is offline")
}

###########################################################################################################################################
###########################################################################################################################################

IF (Test-Connection $Router -Quiet -Count 4) {
    Write-Output (" ")
    Write-Output (" ")
    Write-Output (" ")
    Write-Output (" ")
    Write-Output (" ")
    Write-Output (" ")
    Write-Output ("Router: $Router is back online")
    Write-Output (" ")
    Write-Output (" ")
}

###########################################################################################################################################
###########################################################################################################################################
}#END Process

END {
#Remove-Item $NewBatchFilePath -Force -ErrorAction SilentlyContinue
#Remove-Item $NewTXTFilePath -Force -ErrorAction SilentlyContinue
}#END END

}#END Function Restart-Router

