CLS

Function Get-OracleQuery {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    #[Parameter()]
    #[String]$UserName = "username",
    #[Parameter()]
    #[String]$Password = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=$AppID /p Query="Safe=xxx;Folder=Root;Object=xxx" /o Password),
    #[String]$Password = "",
    [Parameter()]
    # "//HOST:PORT/Instance.Domain.com"
    [String]$DataSource = "//Ip_address/Company",
    [Parameter()]
    [String]$OracleManagedDataAccessDLLPath = "C:\Oracle-Developer\odp.net\managed\common\Oracle.ManagedDataAccess.dll"

    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

#########################################################################################################################################
#########################################################################################################################################

$To = "messagingadmins@Company-x.com"
$From =  "Companywctx02@Company-x.com"
$SMTPServer = "smtp.Company-x.com"

$Subject = "Oracle Managed Distribution Group ERROR for: New X Team"

#########################################################################################################################################
#########################################################################################################################################

$Password = Get-Content "C:\Automation_Files\Oracle_Password.txt" | ConvertTo-SecureString

$Username = "username"

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
$Command.CommandText = "SELECT * from APPS.ATTRIBUTE_VALUES
                      WHERE ATTRIBUTE_ID = 1234 AND END_DATE > to_date('$Today', 'DD-MON-YYYY')
                      ORDER BY END_DATE"

# this executes the command query, and stores it in a reader variable to be looped through.
$Reader = $Command.ExecuteReader()

}
CATCH {
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'New X Team' encountered an ERROR: " + " 
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
    $Body = ("The Oracle Managed Distribution Group: 'New X Team' encountered an ERROR: " + " 
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
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

$WarningPreference = 'SilentlyContinue'

#########################################################################################################################################
#########################################################################################################################################

$To = "messagingadmins@Company-x.com"
$From =  "Companywctx02@Company-x.com"
$SMTPServer = "smtp.Company-x.com"

$Subject = "Oracle Managed Distribution Group ERROR for: New X Team"

#########################################################################################################################################
#########################################################################################################################################

$Password = Get-Content "C:\Automation_Files\Office365_Password.txt" | ConvertTo-SecureString

$UserName = "O365Sync.ServiceNow@Company.onmicrosoft.com"

$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $Password

#########################################################################################################################################
#########################################################################################################################################

try {
## Create New PS Session

$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
catch{
    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'New X Team' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body
}#END CATCH

#########################################################################################################################################
#########################################################################################################################################

}#END Begin

Process {

Try {

$NewLocations = Get-OracleQuery | select LOCATION_NUM, Value 

$NewGroups = (Get-OracleQuery | select Value -Unique).value 

ForEach ($Group in $NewGroups) {
    $DistributionList = $null
    $Email = $null
    $GroupMod = ($Group -replace " ","")
    $Email = ($GroupMod + "@Company-x.com")
    
    $CheckDG = Get-DistributionGroup -Identity $Email -ErrorAction SilentlyContinue
    
    IF ($CheckDG){
        Write-Host -ForegroundColor Yellow $Group "DistributionGroup already exist"     
    }
    ELSE {
        Write-Host -ForegroundColor Cyan $Group "DistributionGroup Does not exist"
        New-DistributionGroup -Name $GroupMod -DisplayName $Group -Type Security -PrimarySmtpAddress $Email -Notes "This group was automatically created and managed by Oracle." | Out-Null
    }

    Set-DistributionGroup -Identity $Group -ManagedBy @{Add="office365roomadmins@Company.onmicrosoft.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
}

ForEach ($Location in $NewLocations) {

    $DistributionGroupName = $Location.VALUE

    $DistributionGroup = ($DistributionGroupName -replace " ","")

    $DistributionList = (Get-DistributionGroupMember -Identity $DistributionGroup -ErrorAction 'SilentlyContinue').PrimarySmtpAddress

    $LocationNumber = ($Location.LOCATION_NUM <#.ToString("00000")#>)

    $EMAIL = $LocationNumber + "@Company-x.com"

    $WindowsEmailAddress = (Get-User -Identity $EMAIL -ErrorAction 'SilentlyContinue').WindowsEmailAddress

    IF ($WindowsEmailAddress -notin $DistributionList) {
        Write-Host -ForegroundColor Yellow "Adding" $EMAIL "as a member of" $DistributionGroupName
        Add-DistributionGroupMember -Identity $DistributionGroup -Member $EMAIL -BypassSecurityGroupManagerCheck -Verbose 
    } 
    
    ElseIF ($DistributionList -eq $null) {
        Write-Host -ForegroundColor Yellow "Adding" $EMAIL "as a member of" $DistributionGroupName
        Add-DistributionGroupMember -Identity $DistributionGroup -Member $EMAIL -BypassSecurityGroupManagerCheck -Verbose
    }
    
    ELSE {
        Write-Host -ForegroundColor Green "$EMAIL is already a member of $DistributionGroupName"
    }

}#END ForEach ($Location in $NewLocations)
}#END TRY

CATCH {

    Write-Host -ForegroundColor Yellow "Distribution Group ADD Error"

    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'New X Team' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body

}#END CATCH

TRY {

$LocationNumbers = @()

ForEach ($Location in $NewLocations) {
    $LocationNumbers += ($Location.LOCATION_NUM <#.ToString("00000")#>)
}

ForEach ($Member in $DistributionList) {
    
    $Member = (Get-User -Identity $Member).UserPrincipalName

    $MemberName = $Member -replace "@Company-x.com",""

    IF ($MemberName -notin $LocationNumbers) {
        Write-Host -ForegroundColor yellow "$Member is being removed from $DistributionGroup"
        Remove-DistributionGroupMember -Identity $DistributionGroup -Member $Member -BypassSecurityGroupManagerCheck -Confirm:$False -Verbose
    } ELSE {
        Write-Host -ForegroundColor Green "$Member is in $DistributionGroup and is in the Oracle DataBase CompanyP Table"
    }

}#END ForEach ($Member in $DistributionList

}#END TRY

CATCH {

    Write-Host -ForegroundColor Yellow "Distribution Group REMOVE Error"

    $ErrorX = Write-Output $_
    $Body = ("The Oracle Managed Distribution Group: 'New X Team' encountered an ERROR: " + " 
" + ($ErrorX) | Out-String)
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject $Subject -Body $Body

}

}#END Process

END {GSN | RSN}#END END

}#END Function 

Add-OracleUsersToOffice365DistributionGroup