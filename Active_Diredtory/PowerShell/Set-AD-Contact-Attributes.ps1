CLS

Function Set_LicenseeContact {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$StoreNumber = $param1,
    [Parameter()]
    [String]$TargetAddress = $param2
    #[Parameter()]
    #[System.Management.Automation.PSCredential]$Credential
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{

Try {
    $CyberArkPassword = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=xxx.com" /o Password
    # The $UserName variable sets the UserName of the PSCredential
    $UserName = "xxx" 
    # The $Password variable sets the Password of the PSCredential
    $Password = ConvertTo-SecureString -String $CyberArkPassword -AsPlainText -Force
    # The $Credential variable creates the PSCredential for the CyberArk Account and password
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password
}
Catch {
    Write-Output "An Error occured with retrieving the Cyber Ark Credential"
}

Try {

    Get-ADObject -LDAPFilter "objectClass=Contact" -Properties * -Credential $Credential -ErrorAction Stop | Where {$_.Mail -match "$StoreNumber"} | 

    Set-ADObject -Replace @{targetAddress=$TargetAddress}

    Write-Output "Location is " $Store_Number " New Email:" $TargetAddress

}

Catch {
    Write-Output "An Error occured during the change of the AD Contact Target Address"
}

}#END Process
END {}#END END
}# END Function 


Set_LicenseeContact -StoreNumber $param1 -TargetAddress $param2
