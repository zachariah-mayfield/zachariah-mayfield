CLS



Function Send-TextMessage {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter(Mandatory=$true)]
    [string]$PhoneNumber,
    [Parameter()]
    [String]$From = "xxxxx@xxxxx.com",
    [Parameter(Mandatory=$true)]
    [String]$Text,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Verizon", "Project Fi", "Virgin Mobile", "T-Mobile", "Sprint", "Nextel", "MetroPCS", "Boost Mobile", "AT&T", "Alltel", "Cricket")]
    [String]$Carrier,
    [Parameter()]
    $SMTPServer = "xxxxx@xxxxx.com"
    )

$Subject = ' '

$CarrierArray = ("Verizon", "Project Fi", "Virgin Mobile", "T-Mobile", "Sprint", "Nextel", "MetroPCS", "Boost Mobile", "AT&T", "Alltel", "Cricket")

$CarrierDomainArray = ("@vzwpix.com", "@msg.fi.google.com", "@vmpix.com", "@tmomail.net", "@pm.sprint.com", "@messaging.nextel.com", "@mymetropcs.com", 
"@myboostmobile.com", "@mms.att.net", "@mms.alltelwireless.com", "@mms.cricketwireless.net")

If ($CarrierArray.Count -eq $CarrierDomainArray.Count) {

    $CarrierDict = @{}

    For ($ITR=0; $ITR -lt $CarrierArray.Count; $ITR++) {
        $CarrierDict.item($CarrierArray[$ITR]) = $CarrierDomainArray[$ITR]
    }

}

$PhoneNumber = ($PhoneNumber.replace(' ','')+$CarrierDict.Item($Carrier) -as [System.Net.Mail.MailAddress]).Address

Write-Output ("You Sent this Text message: `"$Text`" to the phone number: $PhoneNumber")

Send-MailMessage -From $From -to $PhoneNumber -Subject $Subject -Body $Text -SmtpServer $SMTPServer -Verbose

}


