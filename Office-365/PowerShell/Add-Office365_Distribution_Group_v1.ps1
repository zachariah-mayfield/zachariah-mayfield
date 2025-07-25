CLS

Function Get-OracleQuery {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$UserName = "xxxxxxxxxxxxxxx",
    [Parameter()]
    [String]$Password = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxxxxxxxxxxxxxx /p Query="Safe=xxxxxxxxxxxxxxx;Folder=Root;Object=xxxxxxxxxxxxxxx" /o Password),
    [Parameter()]
    # "//HOST:PORT/Instance.Domain.com"
    [String]$DataSource = "//xxxxxxxxxxxxxxx",
    [Parameter()]
    [String]$OracleManagedDataAccessDLLPath = "C:\xxxxxxxxxxxxxxx\Oracle.ManagedDataAccess.dll"

    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

#########################################################################################################################################
#########################################################################################################################################

$To = "xxxxxxxxxxxxxxx.com"
$From =  "xxxxxxxxxxxxxxx.com"
$SMTPServer = "xxxxxxxxxxxxxxx.com"

$Subject = "Oracle Managed Distribution Group ERROR for: xxxxxxxxxxxxxxx"

#########################################################################################################################################
#########################################################################################################################################

$Password = Get-Content "C:\xxxxxxxxxxxxxxx\Oracle_Password.txt" | ConvertTo-SecureString

$Username = "xxxxxxxxxxxxxxx"

$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

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
$Command.CommandText = "xxxxxxxxxxxxxxx"

# this executes the command query, and stores it in a reader variable to be looped through.
$Reader = $Command.ExecuteReader()

}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'xxxxxxxxxxxxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
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
    $Body = ("The Oracle Managed Distribution Group: 'xxxxxxxxxxxxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

}#END Process

END {
$Connection.Close()
}#END END

}#END Function 

Function Add-OracleUsersToOffice365DistributionGroup {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [String]$DistributionGroup = "xxxxxxxxxxxxxxx"
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$WarningPreference = 'SilentlyContinue'

#########################################################################################################################################
#########################################################################################################################################

$Password = Get-Content "C:\xxxxxxxxxxxxxxx\Password.txt" | ConvertTo-SecureString

$UserName = "xxxxxxxxxxxxxxx.com"

$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

#########################################################################################################################################
#########################################################################################################################################

try {
## Create New PS Session

$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'All xxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

#########################################################################################################################################
#########################################################################################################################################

}#END Begin

Process {

Try {

    $PrimarySmtpAddress = ($DistributionGroup + "@xxxxxxxxxxxxxxx.com") -replace " ",""

    # Current Office 365 List
    $O365_Distribution_List = (Get-DistributionGroupMember -Identity $PrimarySmtpAddress -ErrorAction 'SilentlyContinue').PrimarySmtpAddress

    # Current Oracle List
    $OracleAllxxxxx = (Get-OracleQuery | select EMAIL -Unique).Email

    # Making sure the Group already exists 
    $CheckDG = Get-DistributionGroup -Identity $PrimarySmtpAddress -ErrorAction SilentlyContinue
    
    IF ($CheckDG){
        Write-Host -ForegroundColor Yellow $PrimarySmtpAddress "DistributionGroup already exist"     
    }
    ELSE {
        
        Write-Host -ForegroundColor Cyan $PrimarySmtpAddress "DistributionGroup Does not exist"
        New-DistributionGroup -Name $DistributionGroup -DisplayName $DistributionGroup -Type Security -PrimarySmtpAddress $PrimarySmtpAddress -Notes "This group was automatically created and managed by Oracle." | Out-Null
    }
        Set-DistributionGroup -Identity $Group -ManagedBy @{Add="xxxxxxxxxxxxxxx.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null

}#END TRY

CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'xxxxxxxxxxxxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

TRY {
    ForEach ($Mall in $OracleAllxxxxx) {    
        IF ($Mall -notin $O365_Distribution_List) {
            # Adding the user to the office 365 group, if not in the Office 365 group
            write-host -ForegroundColor Green $Mall
            Add-DistributionGroupMember -Identity $PrimarySmtpAddress -Member $Mall -BypassSecurityGroupManagerCheck
        }
        Else {
            write-host -ForegroundColor Cyan $Mall
        }
    }
}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'xxxxxxxxxxxxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

TRY {
    ForEach ($O365 in $O365_Distribution_List) { 
        IF ($O365 -notin $OracleAllxxxxx) {
            # Removing the user from the Office 365 group, if not in the Oracle database. 
            write-host -ForegroundColor Yellow $O365
            Remove-DistributionGroupMember -Identity $PrimarySmtpAddress -Member $O365 -BypassSecurityGroupManagerCheck -Confirm:$False
        }
    }
}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'xxxxxxxxxxxxxxx' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}

}#END Process
END {GSN | RSN}#END END
}#END Function Add-OracleUsersToOffice365DistributionGroup