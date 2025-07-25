CLS

Function Add-ADSecurityGroup {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$GroupName,
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$OU_Path
    )
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
# This will Define what env the script runs in.

$EnvPathCheck = ("F:\Release\Powershell")

IF (Get-ChildItem -Path $EnvPathCheck | Where-Object {$_.Extension -match ".xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}) {
    Write-Output ("Environment is Prod.")
    $Environment = ("Prod")
}
ElseIf (Get-ChildItem -Path $EnvPathCheck | Where-Object {$_.Extension -match ".xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}) {
    Write-Output ("Environment is Dev.")
    $Environment = ("Dev")
}
else {
    Write-Output ("environment not found.")
    EXIT 
} 

If ($Environment -eq "Prod") {
    # This sets the CyberArk Credentials.
    $Key = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxx /p Query="Safe=xxx;Folder=Root;Object=xxx" /o Password)
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
}
Elseif ($Environment -eq "Dev") {
    $Key = "cf0!!!"
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
}
ELSE {
    Write-Output ("An Enviornment was not specified, exiting script.")
    EXIT
}
#######################################################################################################################################################
}#END Begin
Process {
#######################################################################################################################################################

ForEach ($Name in $GroupName) {

    $CheckGroups = (Get-ADGroup -Filter {SamAccountName -eq $Name} -Server $Server -Credential $Credential -ErrorAction SilentlyContinue)

    IF ($CheckGroups -eq $null) {
        Try{
            New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -DisplayName $GroupName -Path $OU_Path -Server $Server -Credential $Credential -Confirm:$false -ErrorAction Stop
            Write-Output ("Created the Group: $Name")
        }
        Catch {
            $_
        }
    }
    Else {
        Write-Output ("The Security Group: $Name already exists.")
    }

}
#######################################################################################################################################################
}#END Process
END {}#END END
}#END Function 
