CLS



Function Get-OracleQuery {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$UserName = "xxxxx",
    [Parameter()]
    [String]$Password = (& "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxxxx /p Query="Safe=xxxxx;Folder=Root;Object=xxxxx" /o Password),
    [Parameter()]
    # "//HOST:PORT/Instance.Domain.com"
    [String]$DataSource = "//xxxxx",
    [Parameter()]
    [String]$OracleManagedDataAccessDLLPath = "C:\xxxxx\Oracle.ManagedDataAccess.dll",
    [Parameter()]
    [String]$Query = "SELECT * from xxxx.VALUES_V
                      WHERE ATTRIBUTE_ID = 4444 AND END_DATE > to_date('$Today', 'DD-MON-YYYY')
                      ORDER BY END_DATE"
    )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

#########################################################################################################################################
#########################################################################################################################################

$KEY = & "C:\Program Files (x86)\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe" GetPassword /p AppDescs.AppID=xxxxx /p Query="Safe=xxxx;Folder=xxxx;Object=xxxxxx" /o Password

$User = "xxxxx.com"
$PWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

try {
## Create New PS Session

$msoExchangeURL = "https://outlook.office365.com/powershell-liveid/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $UserCredential -Authentication Basic -AllowRedirection
$ImportedSession = Import-PSSession $Session -DisableNameChecking 

}#END TRY
catch{
  Write-Error -Message $_.Exception.Message
}#END CATCH

#########################################################################################################################################
#########################################################################################################################################

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
$Command.CommandText = $Query

# this executes the command query, and stores it in a reader variable to be looped through.
$Reader = $Command.ExecuteReader()

}

Process {

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

}#END Process

END {
$Connection.Close()
}#END END

}#END Function Get-OracleQuery

Function Add-OracleUsersToOffice365DistributionGroup {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END Begin

Process {

Try {

$NewLocations = Get-OracleQuery | select LOCATION_NUM, Value 

$NewGroups = (Get-OracleQuery | select Value -Unique).value

ForEach ($Group in $NewGroups) {
    $DistributionList = $null
    $Email = $null
    $GroupMod = ($Group -replace " ","")
    $Email = ($GroupMod + "@xxxxx.com")
    
    $CheckDG = Get-DistributionGroup -Identity $Email -ErrorAction SilentlyContinue
    
    IF ($CheckDG){
        Write-Host -ForegroundColor Yellow $Group "DistributionGroup already exist"     
    }
    ELSE {
        Write-Host -ForegroundColor Cyan $Group "DistributionGroup Does not exist"
        New-DistributionGroup -Name $GroupMod -DisplayName $Group -Type Security -PrimarySmtpAddress $Email -Notes "This group was automatically created and managed by Oracle." | Out-Null
    }

    Set-DistributionGroup -Identity $Group -ManagedBy @{Add="xxxxx.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
}

ForEach ($Location in $NewLocations) {

    $DistributionGroupName = $Location.VALUE

    $DistributionGroup = ($DistributionGroupName -replace " ","")

    $DistributionList = (Get-DistributionGroupMember -Identity $DistributionGroup -ErrorAction 'SilentlyContinue').PrimarySmtpAddress

    $LocationNumber = ($Location.LOCATION_NUM <#.ToString("00000")#>)

    $EMAIL = $LocationNumber + "@xxxxx.com"

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

}#END CATCH

TRY {

$LocationNumbers = @()

ForEach ($Location in $NewLocations) {
    $LocationNumbers += ($Location.LOCATION_NUM <#.ToString("00000")#>)
}

ForEach ($Member in $DistributionList) {
    
    $Member = (Get-User -Identity $Member).UserPrincipalName

    $MemberName = $Member -replace "@xxxxx.com",""

    IF ($MemberName -notin $LocationNumbers) {
        Write-Host -ForegroundColor yellow "$Member is being removed from $DistributionGroup"
        Remove-DistributionGroupMember -Identity $DistributionGroup -Member $Member -BypassSecurityGroupManagerCheck -Confirm:$False -Verbose
    } ELSE {
        Write-Host -ForegroundColor Green "$Member is in $DistributionGroup and is in the Oracle DataBase xxxxx Table"
    }

}#END ForEach ($Member in $DistributionList

}#END TRY

CATCH {

Write-Host -ForegroundColor Yellow "Distribution Group REMOVE Error"

}

}#END Process

END {}#END END

}#END Function Add-OracleUsersToOffice365DistributionGroup