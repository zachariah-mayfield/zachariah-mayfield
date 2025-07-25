CLS

$StartTime = (Get-Date).ToUniversalTime()

Function Get-OracleQuery {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$UserName = "UserName",
    [Parameter()]
    [String]$Password = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password),
    #[String]$Password = "Password Goes Here",
    [Parameter()]
    # "//HOST:PORT/Instance.Domain.com"
    [String]$DataSource = "//Server/Folder",
    [Parameter()]
    [String]$OracleManagedDataAccessDLLPath = "C:\Folder\Oracle.ManagedDataAccess.dll"

    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

#########################################################################################################################################
#########################################################################################################################################

$To = "recipent"
$From =  "sender"
$SMTPServer = "EmailServer"

$Subject = "Oracle Managed Distribution Group ERROR"

#########################################################################################################################################
#########################################################################################################################################

TRY {

$Connection = $null

# This add the appropiate DLL to be able to give you the .NET Commands to be able to access the Oracle DataBase.
Add-Type -Path $OracleManagedDataAccessDLLPath

# This creates your connection string for your connection.
$Connection_String = "User Id=$UserName;Password=$Password;Data Source=$DataSource"

# This creates your connection to the Oracle DataBase.
$Connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($Connection_String)

# This opens your connection to the database.
$Connection.Open()  

# This is your command Variable to allow you to run commands for querying the oracle database.
$Command = $Connection.CreateCommand()

$Today = (Get-date).ToString('dd-MMM-yyyy') 

# This is you Query syntax.
######################################################################################################################
$Command.CommandText = "SELECT $location
FROM APPS.Server
WHERE LOCATION_STATUS = 'OPEN'
ORDER BY $location
"

# this executes the command query, and stores it in a reader variable to be looped through.
$Reader = $Command.ExecuteReader()

}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    #Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

}

Process {

TRY {

$Array_Properties = @()

# This is a While loop to loop though all of the values for each of the rows and columns in the database table.
While ($Reader.Read()) {

    for ($ColumnNum=0;$ColumnNum -lt $Reader.FieldCount;$ColumnNum++) {
        #Write-Host  $Reader.GetName($ColumnNum) $Reader.GetValue($ColumnNum)
        $Properties += @{$Reader.GetName($ColumnNum) = $Reader.GetValue($ColumnNum);}
    }

    $Output = New-Object -TypeName psobject -Property $Properties

    Write-Output $Output 
    $Array_Properties += $Properties
    $Properties=$null
    
}#END While ($Reader.Read())

}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    #Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

}#END Process

END {
$Connection.Close()
}#END END

}#END Function Get-OracleQuery

Function Run-O365-OracleDistro {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

#########################################################################################################################################
#########################################################################################################################################

$To = "recipent"
$From =  "sender"
$SMTPServer = "EmailServer"

$Subject = "Oracle Managed Distribution Group ERROR"

#########################################################################################################################################
#########################################################################################################################################

$KEY = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=$Safe;Folder=Root;Object=$Object" /o Password)

$Password = ConvertTo-SecureString -String $KEY -AsPlainText -Force

$UserName = "UserName"

$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

## Create New PS Session

$ExchangeURL = "https://ExchangeServer/PowerShell/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

#########################################################################################################################################
#########################################################################################################################################
}
Process {

$OracleData = Get-OracleQuery

$ParentPath = ("C:\Excel\Distributions")

$Path2 = "$ParentPath\Excel.xlsx"

$Excel2 = Import-Excel -Path $Path2

# This is a PowerShell Dictionary of all of the group members email addresses, that will be added to the Distribution groups.
$Dictionary = @{} 

# This is a PowerShell Dictionary of all the Distribution group names to their abbreaveated name.
$Trans = @{}

# This is a loop for $Excel2 to loop through all of the Dictionary items and set them to the coresponding abbreaveated names.   
ForEach ($Row2 in $Excel2) {

    IF ($Row2.'String') {
        $Trans.item($Row2.'String') = $Row2.'String'
    }
}
# This is a loop for $Excel to loop through all of the $Emails in the $Dictionary items and set them to the coresponding $Row abbreaveated names.   
ForEach ($Row in $OracleData) {
    
    $Emails = @()
    
    IF (-not ([string]::IsNullOrEmpty($Row.String))) {
        $BCEmail = (($Row.String) -replace " ",".") + "@Company.com"
        $Emails += ($BCEmail)
    }
    
    IF (-not ([string]::IsNullOrEmpty($Row.EMAIL))) {
        $Emails += ($Row.EMAIL)
    }
    
    IF (-not ([string]::IsNullOrEmpty($Row.String_NAME))) {
        $Emails += (($Row.String_NAME) -replace " ",".") + "@Company.com"
    }
    
    IF (-not ([string]::IsNullOrEmpty($Row.String))) {
        $Dictionary.Item($Row.String) += $Emails
    }
}

# This will loop through all of the Distribution Group Names.
ForEach ($DistributionGroup in $Dictionary.Keys) {
    
    # These are all of the group members from the excel list.
    $GroupMember = $Dictionary.Item($DistributionGroup)
    #Write-Host -ForegroundColor Yellow $GroupMember
    # These are all of the translated Distribution Group names from the Abbreviated list.
    $DistroGroup = (($Trans.item($DistributionGroup)) -replace " ","")
    # These are all of the translated Distribution Group names from the Abbreviated list.
    $DisplayName = (($Trans.item($DistributionGroup)))
    #Write-Host -ForegroundColor Cyan $DistroGroup
    # This sets the distribution group names
    $DistroEmail = (($Trans.item($DistributionGroup) -replace " ","") + "@Company.com")
    #Write-Host -ForegroundColor Green $DistroEmail
    
    # This is a Check to see if the Distribution Group exists
    $CheckDG = ((Get-DistributionGroup -Identity $DistroEmail -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).PrimarySmtpAddress)
    
    IF ($CheckDG) {
        Write-Output ("The Distribution Group: $DistroEmail already exist.")
        
        $RemoveMembers = ((Get-DistributionGroupMember -Identity $DistroEmail).PrimarySmtpAddress) 

        ForEach ($Member in $RemoveMembers) {
            Remove-DistributionGroupMember -Identity $DistroEmail -Member $Member -BypassSecurityGroupManagerCheck -Confirm:$False -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
            Write-Output ("The user: $Member is now being removed from the Distribution Group: $DistroGroup.")
        }

        ForEach ($Member in $GroupMember) {
            Try {
                Add-DistributionGroupMember -Identity $DistroEmail -Member $Member -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
                Write-Output ("The user: $Member is now being added to the Distribution Group: $DistroGroup.")
            }
            Catch {
                If ($_.Exception.Message -match "already a member of the group") {
                    Write-Output ("The user: $Member already exists in the Distribution Group: $DistroGroup.")
                }
                ElseIF ($_.Exception.Message -match "Please make sure that it was spelled correctly or specify a different object.") {
                    Write-Output ("The user: $Member Coundn't be found on the Office 365 portal")
                }
                Else {
                    Write-Error -Message $_.Exception.Message
                }
            }
        }
    }
    Else {
        Write-Host -ForegroundColor Yellow ("The Distribution Group: $DistroEmail does NOT exist.")
        Try {
            New-DistributionGroup -Name $DistroGroup -DisplayName $DisplayName -Type Security -PrimarySmtpAddress $DistroEmail -ErrorAction Stop -WarningAction SilentlyContinue  | Out-Null
            Write-Output ("Creating Distribution Group: $DistroGroup with the email address being $DistroEmail")
        }
        Catch {
             Write-Output ("Issue creating Distribution Group: $DistroEmail")
        }
        ForEach ($Member in $GroupMember) {
            Try {
                Add-DistributionGroupMember -Identity $DistroEmail -Member $Member -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
                #Write-Host -ForegroundColor Green ("The user: $Member is now being added to the Distribution Group: $DistroGroup.")
            }
            Catch {
                If ($_.Exception.Message -match "already a member of the group") {
                    Write-Output ("The user: $Member already exists in the Distribution Group: $DistroGroup.")
                }
                ElseIF ($_.Exception.Message -match "Please make sure that it was spelled correctly or specify a different object.") {
                    Write-Output ("The user: $Member coundn't be found in Office 365.")
                }
                Else {
                    Write-Error -Message $_.Exception.Message
                }
            }
        }
    }
    Try {
        Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Add="UserName@company.com"} -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
        Set-DistributionGroup -Identity $DistroGroup -ManagedBy @{Remove="UserName@company.com"} -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
        Add-DistributionGroupMember -Identity $DistroGroup -Member "UserName@company.com" -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
        Add-DistributionGroupMember -Identity $DistroGroup -Member "UserName@company.com" -BypassSecurityGroupManagerCheck -ErrorAction Stop -WarningAction SilentlyContinue -Confirm:$False | Out-Null
    }
    Catch {
        IF ($_.Exception.Message -match "is already a member of the group") {
            Write-Output ("The default user already exists in the Distribution Group: $DistroGroup.")
        }
        Else {
            Write-Output $_
        }
    }
}

}
End {GSN|RSN}
}#END Function Run-O365-OracleDistro

$TimeStamp = (Get-Date).ToString("yyyyMMdd")

Run-O365-OracleDistro | Out-File "C:\Distribution\$TimeStamp.txt" -Append

Write-Output ("The Start time was:  $StartTime") | Out-File "C:\Distribution\$TimeStamp.txt"  -Append

$EndTime = (Get-Date).ToUniversalTime()

Write-Output ("The End time was:  $EndTime") | Out-File "C:\Distribution\$TimeStamp.txt"  -Append