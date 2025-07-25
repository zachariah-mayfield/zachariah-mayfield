CLS

Function Set-SFTP_File {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin {
#########################################################################################################################################
#########################################################################################################################################
# This is a check to see if the Posh-SSH module is already installed. 
If (!(Get-Module -Name Posh-SSH)) {
    Write-Output ("POSH-SSH Module is not installed.")
    Write-Output ("Running the following command: Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\Posh-SSH\2.0.2\Posh-SSH.psd1' -Force")
    # This will install the module if it's not already installed.
    Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\Posh-SSH\2.0.2\Posh-SSH.psd1' -Force
    # Save-Module -Name Posh-SSH -Path "C:\Users\xxx\Desktop\" -Force
}
Else {
    Write-Output ("POSH-SSH Module is installed.")
}
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
#$KEY = ("xxxxxxxxxxxx")
# This is the CyberArk program that will use the supplied commands to retrieve the CyberArk Key
$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="$Safe;Folder=Root;object=$Object" /o Password
# This will convert the plain text key to the secure string to be used for the CyberArk UserCredential
$Password = ConvertTo-SecureString -String $KEY -AsPlainText -Force
# This is the CyberArk User Name. 
$UserName = "xxx"
# This will create a new object for the CyberArk UserCredential
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password
# "https://files.biz/" or "xx.xx.xx.xx"
$SFTPServer = "files.biz"
# This will create a new SFTP session using the supplie credentials.
New-SFTPSession -ComputerName $SFTPServer -Credential $UserCredential -AcceptKey -Force | Out-Null
#########################################################################################################################################
#########################################################################################################################################
}#END Begin
Process {
# This varriable is a list of all the old SFTP files.
$Old_SFTP_Files = ("//Home/xxx/dev/O365/O365DistributionGroups.CSV",
                   "//Home/xxx/dev/O365/O365SharedMailboxes.CSV",
                   "//Home/xxx/dev/O365/O365ConferenceRooms.CSV")

# This will loop through the list of all the old SFTP files and delete them.
ForEach ($Old_File in $Old_SFTP_Files) {
    Try {
        Remove-SFTPItem -SessionId 0 -Path $Old_File -ErrorAction Stop -Verbose -Force
    }
    Catch {
        $_
    }
}

# This is a varriable for the SFTP Parent file path.
$SFTP_File_Location = "//Home/xxx/dev/O365"

# This is a varriable for all of the new files that will be copied to the SFTP Parent file path.
$Local_Files = ("D:\xxx_Data\Office_365\O365DistributionGroups.CSV",
                "D:\xxx_Data\Office_365\O365SharedMailboxes.CSV",
                "D:\xxx_Data\Office_365\O365ConferenceRooms.CSV")

# This is a loop that will add each file to the SFTP parent file path.
ForEach ($Local_File in $Local_Files) {
    Try {
        Set-SFTPFile -SessionId 0 -LocalFile $Local_File -RemotePath $SFTP_File_Location -Verbose -Overwrite -ErrorAction Stop
    }
    Catch {
        $_
    }
}

}#END Process

END {
# This will end all current SFTP Sessions.
Get-SFTPSession | Remove-SFTPSession | Out-Null

# This is a loop that will delete all of the local files that were created. 
ForEach ($file in $Local_Files) {
    Remove-Item -Path $file -Force -Confirm:$false -ErrorAction SilentlyContinue
}
}

}#END Function

Set-SFTP_File