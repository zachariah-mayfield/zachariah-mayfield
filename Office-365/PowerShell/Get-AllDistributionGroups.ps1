CLS

Function Get-AllDistributionGroups {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$UserName = "UserName",
    [Parameter()]
    [String]$Key = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password),
    #[String]$Key = "Password Goes Here",
    [Parameter()]
    [SecureString]$Password = (ConvertTo-SecureString -String $KEY -AsPlainText -Force),
    [Parameter()]
    [System.Management.Automation.PSCredential]$Credential = (New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password)
)

Begin {
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

try {
## Create New PS Session

$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $Credential -Authentication Basic -AllowRedirection
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH

}

Process {

$AllDistributionGroups = (Get-DistributionGroup -ResultSize "Unlimited")

$AllDistributionGroups | Select DisplayName, PrimarySmtpAddress

}#END Process

END{}

}

Get-AllDistributionGroups