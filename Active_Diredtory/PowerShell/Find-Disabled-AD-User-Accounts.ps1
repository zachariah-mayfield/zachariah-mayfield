CLS

Function Find-DisabledADUserAccounts {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
# This will Define what env the script runs in.
$EnvPathCheck = ("C:\Folder\Powershell")
IF (Get-ChildItem -Path $EnvPathCheck | Where-Object {$_.Extension -match ".prod"}) {
    Write-Output ("Environment is Prod.")
    $Environment = ("Prod")
}
ElseIf (Get-ChildItem -Path $EnvPathCheck | Where-Object {$_.Extension -match ".dev"}) {
    Write-Output ("Environment is Dev.")
    $Environment = ("Dev")
}
else {
    Write-Output ("environment not found.")
    EXIT
} 

# This will Define what env the script runs in.
If ($Environment -eq "Prod") {
    # This sets the CyberArk Credentials.
    $Key = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password)
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
    $Domain = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
Elseif ($Environment -eq "Dev") {
    $Key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
    $Domain = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
ELSE {
    Write-Output ("An Enviornment was not Specified, exiting Script.")
    EXIT
}

# Setting the $FileDate Varriable
$FIleDate = (Get-date).ToString('dd-MM-yy')
# Setting the $FolderPath Varriable
$FolderPath = ("C:\TEST")
# Creating the $FolderPath if it does not exist, and setting the $FileName Varriable.
IF (!(Test-Path $FolderPath)) {
    New-Item -ItemType Directory -Force -Path $FolderPath -ErrorAction Stop
    $FileName = ("$FolderPath\$FIleDate`DisabledADUserAccounts.txt")
}
Else {
    # Setting the $FileName Varriable.
    $FileName = ("$FolderPath\$FIleDate`DisabledADUserAccounts.txt")
}
#######################################################################################################################################################
}#END Begin
Process {

# Marked for Deletion OU (xxxx)
$MarkedforDeletion  = ("OU=Marked For Deletion,dc=$Domain,dc=com") # ("OU=Marked For Deletion,DC=xxxxTest,DC=com")

# Find all disabled user accounts Get all of the users SamAccountName
$DomainUsersgroup = ("OU=Basic Users,OU=Users,OU=Corp,DC=$Domain,DC=com")

# Take out - - - Where {$_.DistinguishedName -match "xxxxx"} - - -
$DisabledUsers = (Search-ADAccount -AccountDisabled -SearchBase $DomainUsersgroup -Server $Server -Credential $Credential -ErrorAction SilentlyContinue | 
Where {$_.DistinguishedName -match "xxxxxx"} | Select SamAccountName).SamAccountName

ForEach ($Identity in $DisabledUsers) {
    
    $User = (Get-ADUser -Identity $Identity -Properties * -Server $Server -Credential $Credential -ErrorAction SilentlyContinue)
    
    # Hide account from the Exchange Address Lists
    $User.msExchHideFromAddressLists = $true
    Try {
        Set-ADUser -Instance $user -Server $Server -Credential $Credential -ErrorAction Stop
        Write-Host -ForegroundColor Yellow ("Hiding the user account:") $User.SamAccountName ("from the Exchange Address Lists.")
    }
    Catch {
        $_
    }
    # Get all AD Groups that the User is member of. 
    $CheckGroup = ((Get-ADPrincipalGroupMembership -Identity $Identity -Server $Server -Credential $Credential -ErrorAction SilentlyContinue) | Select SamAccountName).SamAccountName

    # Move the Account to the Marked for Deletion OU
    Try {
        Move-ADObject -Identity $User -TargetPath $MarkedforDeletion -ErrorAction Stop -Server $Server -Credential $Credential
        Write-Host -ForegroundColor Yellow ("Moving the user:") $User.SamAccountName ("to the AD Marked for Deletion OU.") 
    }
    Catch {
        $_
    }
    # Remove user from all Distribution Lists
    ForEach ($Group in $CheckGroup) {

        $CheckADDistros = (Get-ADGroup -Identity $Group -Server $Server -Credential $Credential -ErrorAction SilentlyContinue | 
        Select DistinguishedName | Where {$_.DistinguishedName -match "Distribution Groups"})

        IF ($CheckADDistros) {
            Try {
                #Remove-ADGroupMember -Identity $Group -Members $User.SamAccountName -Server $Server -Credential $Credential -Confirm:$false -Verbose
                Write-Host -ForegroundColor Yellow ("Removing the user:") $User.SamAccountName ("from the AD Distribution Group:") $Group
            }
            Catch {
                $_
            }
        }
    
    }

}

}#END Process
END {}
}#END Function Find-DisabledADUserAccounts


Find-DisabledADUserAccounts
