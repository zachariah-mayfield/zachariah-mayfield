CLS

$UserName = ("fortinet@")

$CyberArkPassword = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password)

$Password = ("`"xxxxxxxxxxxx`"")

$Router = ("152.24.239.1")

$NewTXTFilePath = ("C:\temp\SSH.txt")

[String]$TXTContent = ("execute date
execute reboot
y
exit")

$TXTContent | Out-File $NewTXTFilePath -Force ascii

$NewBatchFilePath = ("C:\temp\SSH-To-Router.BAT")

[String]$BatchContent = ("CLS

`"C:\Program Files\PuTTY\Plink.exe`" -ssh fortinetpas_service@$Router -P 22 -pw $Password -v -m `"C:\temp\SSH.txt`"

Exit")

$BatchContent | Out-File $NewBatchFilePath -Force ascii

$RunSSHCommand = Start-Process -FilePath "C:\temp\SSH-To-Router.BAT" -NoNewWindow

Sleep -Seconds 15

While (!(Test-Connection $Router -Quiet -Count 1)) {
    Write-Output ("Router: $Router is offline")
}

ping $Router
    
Remove-Item $NewBatchFilePath -Force

Remove-Item $NewTXTFilePath -Force