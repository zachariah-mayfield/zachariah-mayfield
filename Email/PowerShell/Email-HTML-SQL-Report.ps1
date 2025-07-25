Param(
    [parameter(Mandatory=$false)][string]$SQL_Server = 'SQL_Server\folder',
    [parameter(Mandatory=$false)][string]$Database = 'Database',
    [parameter(Mandatory=$false)][string]$To = 'To',
    [parameter(Mandatory=$false)][string]$Email_Password = 'Password',
    [parameter(Mandatory=$false)][string]$AssignmentGroup = "Management",
    [parameter(Mandatory=$false)][string]$DaysAgo,
    [parameter(Mandatory=$false)][string]$TodaysDate, 
    [parameter(Mandatory=$false)][ValidateSet('String','String')][string]$Instance = 'String',
    [parameter(Mandatory=$false)][string]$ServiceNowSvcAccount = 'username',
    [parameter(Mandatory=$false)][string]$ServiceNowSvcPassword = 'Password'
)
Clear-Host
$Global:QACount = 0
$Global:ProdCount = 0
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1

IF (!([string]::isNullorempty($TodaysDate))) {
    $TodaysDateX = get-date $TodaysDate -Format 'yyyy-MM-dd'
}
else {
    $TodaysDateX = (Get-Date).ToString("yyyy-MM-dd")
}

IF (!([string]::isNullorempty($DaysAgo))) {
    $DaysAgoX = get-date $DaysAgo -Format 'yyyy-MM-dd'
}
else {
    $DaysAgoX = (Get-Date).AddDays(-(7)).ToString("yyyy-MM-dd")
}

$Query = "SELECT	/* [ConfigurationTracking].[dbo].[ConfigItemVersion].[ConfigItemVersionId], 
[ConfigurationTracking].[dbo].[ConfigItemVersion].[ConfigItemId], */
[ConfigurationTracking].[dbo].[ConfigItemVersion].[VersionId],
[ConfigurationTracking].[dbo].[ActivityInstance].[ResultCode],
[ConfigurationTracking].[dbo].[ActivityInstance].[ResultDate],
[ConfigurationTracking].[dbo].[ActivityInstance].[ExpectedDate],
[ConfigurationTracking].[dbo].[ConfigItem].[ConfigItemName]
FROM	[ConfigurationTracking].[dbo].[ActivityInstance] 
INNER JOIN	[ConfigurationTracking].[dbo].[ConfigItemVersion]
ON		[ConfigurationTracking].[dbo].[ConfigItemVersion].ConfigItemVersionId = [ConfigurationTracking].[dbo].[ActivityInstance].[ConfigItemVersionId] 
INNER JOIN	[ConfigurationTracking].[dbo].[ConfigItem] 
ON		[ConfigurationTracking].[dbo].[ConfigItem].ConfigItemId = [ConfigurationTracking].[dbo].[ConfigItemVersion].[ConfigItemId] 
WHERE	[ConfigurationTracking].[dbo].[ActivityInstance].[ExpectedDate] >='$($DaysAgoX)' and [ConfigurationTracking].[dbo].[ActivityInstance].[ExpectedDate] <='$($TodaysDateX)'"

$connectionString = ("Server = $SQL_Server ; Database = $Database ; Integrated Security=True")
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText  = $Query
$result = $command.ExecuteReader()
$Global:QACount = $result.FieldCount
$table = new-object System.Data.DataTable
$table.Load($result) 
$connection.Close()

$QA_Body = ForEach ($ResponseX in $table) {
    '<tr><td style="width: "10%";">',$($ResponseX.VersionId ),'</td>'
    '<td style="width: "20%";">',$($ResponseX.ResultCode),'</td>'
    '<td style="width: "10%";">',$($ResponseX.ResultDate),'</td>'
    '<td style="width: "10%";">',$($ResponseX.ExpectedDate),'</td>'
    '<td style="width: "60%";">',$($ResponseX.ConfigItemName),'</td></tr>'
}

$From = 'from'
$HeaderAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ServiceNowSvcAccount, $ServiceNowSvcPassword)))
$SNOWSessionHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$SNOWSessionHeader.Add('Authorization',('Basic {0}' -f $HeaderAuth))
$SNOWSessionHeader.Add('Accept','application/json')
$ServiceNowURL = "https://$($Instance)/api/Company`?sysparm_query=assignment_group.name=$($AssignmentGroup)^start_date>$($DaysAgoX)^start_date<$($TodaysDateX)"
$Responses = (Invoke-RestMethod -Uri $ServiceNowURL -Method GET -Headers $SNOWSessionHeader)
$Global:ProdCount = $Responses.result.Count 

$Prod_Body = ForEach ($Response in $Responses.result) {
    '<tr><td style="width: "10%";">',$($Response.number),'</td>'
    '<td style="width: "20%";">',$($Response.cmdb_ci),'</td>'
    '<td style="width: "10%";">',$($Response.close_code),'</td>'
    '<td style="width: "60%";">',$($Response.work_notes),'</td></tr>'
}

$HeaderInfo = 2

#HTML Template
$HTML_Email_Body = @"
<h1 style="text-align: center;"><span style="color: #ffffff; background-color: #008080;"> Weekly DA Release Report During $($DaysAgoX) &amp; $($TodaysDateX) </span></h1>
<p>
<h3 style="text-align: left;"><span style="color: #ffffff; background-color: #008080;"> There were $($Global:QACount - $HeaderInfo) Lab Releases: </span></h3>
</p>
<table style="height: 40px;" width="100%"; border="1"; colspan="5"">
<tbody>
<tr>
<th>VersionId</th>
<th>ResultCode</th>
<th>ResultDate</th>
<th>ExpectedDate</th>
<th>ConfigItemName</th>
</tr>
$QA_Body
</tbody>
</table>
<p>
<!-- #######  Seperating Tables #########-->
</p>
<p>
<h3 style="text-align: left;"><span style="color: #ffffff; background-color: #008080;"> There were $($ProdCount) Prod releases: </span></h3>
</p>
<table style="height: 40px;" width="100%"; border="1"; colspan="4"">
<tbody>
<tr>
<th>number</th>
<th>cmdb_ci</th>
<th>close_code</th>
<th>work_notes</th>
</tr>
$Prod_Body
</tbody>
</table>
"@

$SmtpServer = 'smtp.Company.local'
$Port = '587'
$Subject = "DA Deployments During $($DaysAgoX) & $($TodaysDateX)"
$Email_user_name = 'zm@Company.com'
$Password = (ConvertTo-SecureString $Email_Password -AsPlainText -Force) 
$Credential = New-Object System.Management.Automation.PSCredential ($Email_user_name, $PassWord)

$SendEmail_Message = New-Object System.Net.Mail.MailMessage $From, $To
$SendEmail_Message.Subject = $Subject
$SendEmail_Message.IsBodyHTML = $true
$SendEmail_Message.BODY = $HTML_Email_Body

$smtp = New-Object Net.Mail.SmtpClient($SmtpServer)
$smtp.Credentials = $Credential
$smtp.EnableSsl = $true
$smtp.Port = $Port
$smtp.Send($SendEmail_Message)
