CLS

Function Get-SA_PW_Expiration {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [Switch]$Create_EventLog
    )
Begin {
    $ServiceAccounts = (Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $false} `
–Properties "SamAccountName", "UserPasswordExpiryTimeComputed","PasswordNeverExpires", "pwdLastSet", * -SearchBase "OU=ServiceAccounts,OU=Enterprise Services")
}
Process {
    ForEach ($User in $ServiceAccounts) {
        $UserProperties = [Ordered]@{}
        $ExpiryDate = ([datetime]::FromFileTime($User.'UserPasswordExpiryTimeComputed'))
        $Today = (Get-Date)
        $DaysToExpire = New-TimeSpan -Start $Today -End $ExpiryDate
        IF ($Create_EventLog -eq $false -and $DaysToExpire.Days -lt 7) {
            $UserProperties = New-Object -TypeName PSObject
            $UserProperties | Add-Member -MemberType NoteProperty -Name ”SamAccountName” -Value ($User.SamAccountName)
            $UserProperties | Add-Member -MemberType NoteProperty -Name ”PasswordNeverExpires” -Value ($User.PasswordNeverExpires)
            $UserProperties | Add-Member -MemberType NoteProperty -Name ”Days Left Before PW Expires” -Value ($DaysToExpire.Days)
            $UserProperties | Add-Member -MemberType NoteProperty -Name ”Password Last Set Date” -Value ([datetime]$User.pwdLastSet)
            $UserProperties | Add-Member -MemberType NoteProperty -Name ”Expiry Date” -Value ($ExpiryDate.Date)
            $UserProperties
        }
        IF ($Create_EventLog -eq $true -and $DaysToExpire.Days -lt 7) {
            #New-EventLog -LogName _xCustomSplunkAlertsx -Source ServiceAccountPWExpire_Monitor -ErrorAction SilentlyContinue
            $Message = [Ordered]@{}
            $Message.add( "SamAccountName", (”SamAccountName: ” + [String]$User.SamAccountName))
            $Message.add( " BlankLine1",("
"))
            $Message.add( "PasswordNeverExpires", (”PasswordNeverExpires: ” + [String]$User.PasswordNeverExpires))
            $Message.add( " BlankLine2",("
"))
            $Message.add( "DaysLeftBeofrePWExpires", (”Days Left Beofre PW Expires: ” + [String]$DaysToExpire.Days))
            $Message.add( " BlankLine3",("
"))
            $Message.add( "PasswordLastSetDate", (”Password Last Set Date: ” + [String][datetime]$User.pwdLastSet))
            $Message.add( " BlankLine4",("
"))
            $Message.add( "ExpiryDate", (”Expiry Date: ” + [String]$ExpiryDate.Date))
            $Message.add( " BlankLine5",("
"))
            Write-EventLog -LogName xCustomSplunkAlertsx -Source ServiceAccountPWExpire_Monitor -EntryType Warning -EventId 1111111 -Message $Message.Values
            $Message
        }
    }
}#END Process 
END{}
}# END Function

Get-SA_PW_Expiration -Create_EventLog
