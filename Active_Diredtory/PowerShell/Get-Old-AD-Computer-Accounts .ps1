Function Get-Old_ADComputerAccounts {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Prod","Dev")]
    [String]$Environment,
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Windows_7_Computer_Accounts","Windows_7_Staging_Computer_Accounts","Windows_8_Computer_Accounts","Windows_10_Computer_Accounts",
    "Workstations_Computer_Accounts","Location_Computer_Accounts","Mac_Computer_Accounts")]
    [String]$ComputerType
    )
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
# This will Define what env the script runs in.
If ($Environment -eq "Prod") {
    # This sets the CyberArk Credentials.
    $Key = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password)
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
Elseif ($Environment -eq "Dev") {
    $Key = "XXXX"
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
}
ELSE {
    Write-Output ("An Enviornment was not Specified, exiting Script.")
    EXIT
}
# OLD Windows_7_Computer_Accounts
IF ($ComputerType -eq "Windows_7_Computer_Accounts") {
    $SearchBase = ("ou=Windows7,ou=Computers,ou=XXXX,dc=XXX,dc=com")
}
# OLD Windows_7_Staging_Computer_Accounts
EsleIF ($ComputerType -eq "Windows_7_Staging_Computer_Accounts") {
    $SearchBase = ("ou=Windows7Staging,ou=Computers,ou=XXXX,dc=XXX,dc=com")
}
# OLD Windows_8_Computer_Accounts
EsleIF ($ComputerType -eq "Windows_8_Computer_Accounts") {
    $SearchBase = ("ou=Windows8,ou=Computers,ou=XXXX,dcxxx-A,dc=com")
}
# OLD Windows_10_Computer_Accounts
EsleIF ($ComputerType -eq "Windows_10_Computer_Accounts") {
    $SearchBase = ("ou=Windows10,ou=Computers,ou=XXXX,dc=XXXX,dc=com")
}
# OLD Workstations_Computer_Accounts
EsleIF ($ComputerType -eq "Workstations_Computer_Accounts") {
   $SearchBase = ("ou=Workstations,ou=Computers,ou=XXXXX,dc=XXXXX,dc=com") 
}
# OLD Location_Computer_Accounts
EsleIF ($ComputerType -eq "Location_Computer_Accounts") {
    $SearchBase = ("ou=Computers,ou=Units,dcXXXXX,dc=com")
}
# OLD Mac_Computer_Accounts
EsleIF ($ComputerType -eq "Mac_Computer_Accounts") {
    $SearchBase = ("ou=Mac,ou=Computers,ou=XXXX,dc=XXXXX,dc=com")
}
ELSE {
    Write-Output ("A ComputerType was not Specified, exiting Script.")
    EXIT
}
# Setting the $Date Varriable to 180 days in the Past.
$Date = [DateTime]::Today.AddDays(-90)

# Setting the $Filter Varriable for the Get-ADComputers command.
$Filter = ('PasswordLastSet -ge $Date')
#######################################################################################################################################################
}#END Begin
Process {

Try {
    Get-ADComputer -Filter $Filter -Properties passwordLastSet, whencreated -Credential $Credential -Server $Server -SearchBase $SearchBase
}
Catch {
    $_
}

<####
### Get-ADComputer | Remove-ADComputer -Server $Server -Credential $Credential -Confirm:$false ###
#####>

}#END Process
END {}
}#END Function

