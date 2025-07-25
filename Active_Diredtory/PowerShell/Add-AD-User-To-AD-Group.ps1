Function Set-ADUserToSecurityGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$UserName,
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$SecurityGroup,
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Windows","Linux")]
    [String]$OS
    )
Begin{
#######################################################################################################################################################
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
# This sets the warring preference
$WarningPreference = "SilentlyContinue"
# This will Define what env the script runs in.
$EnvPathCheck = ("F:\Release\Powershell")

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

If ($Environment -eq "Prod") {
    # This sets the CyberArk Credentials.
    $Key = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=DevProd-ServiceNowMID-ProcessFlow /p Query="Safe=XXXX;Folder=Root;Object=XXXX" /o Password)
    $CyberArkUserName = "_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
}
Elseif ($Environment -eq "Dev") {
    $Key = "xxxxxx"
    $CyberArkUserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $PassWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $CyberArkUserName, $PassWord
    $Server = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:389"
}
ELSE {
    Write-Output ("An Enviornment was not specified, exiting script.")
    EXIT
}
#######################################################################################################################################################
}#END Begin
Process {
#######################################################################################################################################################

ForEach ($Group in $SecurityGroup) {

    Foreach ($user in $UserName) {
        # Check if $User exists
        $UserCheck = $null
        $UserCheck = (Get-ADUser -Filter {SamAccountName -eq $User} -Properties * -ErrorAction SilentlyContinue -ErrorVariable "UserError" -Server $Server -Credential $Credential)
        IF ($UserCheck -ne $null) {
            Write-Output ("User: $User exists")
    
    #######################################################################################################################################################
            # Check if $SecurityGroup exists
            $GroupCheck = $null
            $GroupCheck = Get-ADGroup -Filter {SamAccountName -eq $Group} -ErrorAction SilentlyContinue -ErrorVariable "SecurityGroupError" -Server $Server -Credential $Credential 
            IF ($GroupCheck -ne $null) {
                Write-Output ("Security Group: $Group exists")
            }
            Else {
                Write-Output ("Security Group: $Group does NOT exist in Active Directory")
            }
        #######################################################################################################################################################
            # Check if $User is already in the $SecurityGroup
            $GroupMember = (Get-ADGroupMember -Identity $Group -Server $Server -Credential $Credential | select SamAccountName).SamAccountName 
            IF ($User -in $GroupMember) {
                Write-Output ("User: $User is already in Security Group: $Group")
            }
            Else {
                Write-Output ("User: $User is NOT in Security Group: $Group")
                # Check if $OS Selection is Linux. 
                $Add_GroupMemeber = $true
                                                                                                                                                                                                                                                                                                                                                                                                                                                                IF ($OS -eq "Linux") {
                IF (-not ([string]::IsNullOrEmpty($UserCheck.msSFU30NisDomain))) {
                    Write-Host -ForegroundColor Yellow "Checking user unix Attribute: `'NIS Domain`' is set to: " $UserCheck.msSFU30NisDomain
                }
                ELSE {
                    $UserCheck.msSFU30NisDomain = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                    Try {
                        Set-ADUser -Instance $UserCheck -Server $Server -Credential $Credential -ErrorAction Stop
                        Write-Host -ForegroundColor Green "The unix Attribute: `'NIS Domain`' was set to null. Now setting unix Attribute: `'NIS Domain`' to: xxxxxxxxx-xxxxxxxxx-x"
                    }
                    Catch {
                        $Add_GroupMemeber = $false
                        If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                            Write-Output ("ERROR : ")
                            Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                        }
                        Else {
                            Write-Output ("ERROR : ")
                            $_
                        }
                    }
                }    
                IF (-not ([string]::IsNullOrEmpty($UserCheck.uidNumber))) {
                    Write-Host -ForegroundColor Yellow "Checking user unix Attribute: `'UID`' is set to: " $UserCheck.uidNumber
                }
                ELSE {
                    $LastUIDNumber = (Get-ADUser -xxxxxxxxxter {uidNumber -gt 0} -Properties uidNumber -Server $Server -Credential $Credential | Sort-Object -Property uidNumber -Descending | Select-Object uidNumber)
                    $UID = ($LastUIDNumber[0].uidNumber + 1)
                    $UserCheck.uidNumber = $UID
                    Try {
                        Set-ADUser -Instance $UserCheck -Server $Server -Credential $Credential -ErrorAction Stop
                        Write-Host -ForegroundColor Green "The unix Attribute: `'UID`' was set to null. Now setting unix Attribute: `'UID`' to: $UID" ######################################
                    }
                    Catch {
                        $Add_GroupMemeber = $false
                        If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                            Write-Output ("ERROR : ")
                            Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                        }
                        Else {
                            Write-Output ("ERROR : ")
                            $_
                        }
                    }
                }
                IF (-not ([string]::IsNullOrEmpty($UserCheck.loginShell))) {
                    Write-Host -ForegroundColor Yellow "Checking user unix Attribute: `'Login Shell`' is set to: " $UserCheck.loginShell
                }
                ELSE {
                    $UserCheck.loginShell = "/bin/bash"
                    Try {
                        Set-ADUser -Instance $UserCheck -Server $Server -Credential $Credential -ErrorAction Stop
                        Write-Host -ForegroundColor Green "The unix Attribute: `'Login Shell`' was set to null. Now setting unix Attribute: `'Login Shell`' to: /bin/bash"
                    }
                    Catch {
                        $Add_GroupMemeber = $false
                        If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                            Write-Output ("ERROR : ")
                            Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                        }
                        Else {
                            Write-Output ("ERROR : ")
                            $_
                        }
                    }
                }
                IF (-not ([string]::IsNullOrEmpty($UserCheck.unixHomeDirectory))) {
                    Write-Host -ForegroundColor Yellow "Checking user unix Attribute: `'Home Directory`' is set to: " $UserCheck.unixHomeDirectory
                }
                ELSE {
                    $UserCheck.unixHomeDirectory = "/home/" + $UserCheck.SamAccountName
                    Try {
                        Set-ADUser -Instance $UserCheck -Server $Server -Credential $Credential -ErrorAction Stop
                        Write-Host -ForegroundColor Green ("The unix Attribute: `'Home Directory`' was set to null. Now setting unix Attribute: `'Home Directory`' to: ") '/home/'$UserCheck.SamAccountName
                    }
                    Catch {
                        $Add_GroupMemeber = $false
                        If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                            Write-Output ("ERROR : ")
                            Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                        }
                        Else {
                            Write-Output ("ERROR : ")
                            $_
                        }
                    }
                }
                IF (-not ([string]::IsNullOrEmpty($UserCheck.gidnumber))) {
                    Write-Host -ForegroundColor Yellow "Checking user unix Attribute: `'Primary group name/GID`' is set to: " $UserCheck.gidnumber
                }
                ELSE {
                    $UserCheck.gidnumber = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                    Try {
                        Set-ADUser -Instance $UserCheck -Server $Server -Credential $Credential -ErrorAction Stop
                    }
                    Catch {
                        $Add_GroupMemeber = $false
                        If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                            Write-Output ("ERROR : ")
                            Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                        }
                        Else {
                            Write-Output ("ERROR : ")
                            $_
                        }
                    }
                }
            }#END IF ($OS -eq "Linux")
                TRY {
                    IF ($Add_GroupMemeber -eq $true) {
                        Add-ADGroupMember -Identity $Group -Members $User -Server $Server -Credential $Credential -ErrorAction Stop
                        Write-Output ("Added user: $User to Security Group: $Group")
                    }
                }
                CATCH {
                    If ($_.Exception.Message -match "Insufficient access rights to perform the operation"){
                        Write-Output ("ERROR : ")
                        Write-Output ("Insufficient access rights to perform the operation - This is most likely a domain admin account.")
                    }
                    Else {
                        Write-Output ("ERROR : ")
                        $_
                    }
                }
            }
        }#END IF ($UserCheck -eq $null)
        Else {
            Write-Output ("User: $User does not exist in Active Directory")
        }
     
    }#END Foreach ($user in $UserName)
    
}#END ForEach ($Group in $SecurityGroup)    
     
}#END Process
END {}
}#END Function Set-ADUserToSecurityGroup
