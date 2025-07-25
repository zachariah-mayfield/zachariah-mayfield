CLS

Function Start-Office365Session {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process {
# This is the CyberArk program that will use the supplied commands to retrieve the CyberArk Key
$KEY = "xxx"
#$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xx /p Query="Safe=xx;Folder=Root;Object=xxxxx" /o Password
# This is the CyberArk User Name. 
$UserName = "xx"
# This will convert the plain text key to the secure string to be used for the CyberArk UserCredential
$Password = ConvertTo-SecureString -String $KEY -AsPlainText -Force
# This will create a new object for the CyberArk UserCredential
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password
try {
    ## Create New PS Session
    # This is the mso Exchange URL
    $msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
    # This will create a new PS Session with the supplied User Credentials
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection
    # This will import the PS Session and load all of the Office 365 commands
    $ImportedSession = Import-PSSession $Session -DisableNameChecking 
}
catch{
    Write-Error -Message $_.Exception.Message
}
}#END Process
END {
    GSN | Select -Property Id, Name, ConfigurationName, ComputerName | Format-List -Property Id, Name, ConfigurationName, ComputerName
}
}#END Function

Start-Office365Session