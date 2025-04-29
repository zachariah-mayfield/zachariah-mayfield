# This checks Azure subscriptions for all resources of the type specified.
# Do not run as Administrator. Run as your account with Azure access.
# Spreadsheet with results located at D:\TaskLogs\<date>-AzureResourceList.xlsx

Clear

$FileLocation = "C:\Temp\" 
$PFileLocation = "C:\Temp\"

$AzureUser = "Azure User"
$PSEmailServer = "PS Email Server"
$EmailFrom = "Email From"
$EmailTo = @('Email To') 

$ResourceType = @("VM")


$SubscriptionNames = @("SubscriptionNames")


$TodayDate = (get-date).ToString("yyyyMMdd")


$ExcelObject = New-Object -ComObject Excel.Application
$ExcelObject.visible = $false
$ActiveWorkbook = $ExcelObject.Workbooks.add()
$OutputFileName = ($FileLocation+$TodayDate+"-AzureResourceList"+".xlsx")
if (Test-Path -Path $OutputFileName) {  
    remove-item $OutputFileName 
}
Write-Host "Creating Excel File at "$OutputFileName

Import-Module Az

Write-Host "Az Imported"
<#
$password = Get-Content ($PFileLocation+"pfile.txt") | ConvertTo-SecureString 
$credential = New-Object System.Management.Automation.PsCredential($AzureUser,$password)

Write-host "Password Pulled"

Connect-AzAccount -Credential $credential
#>

$PassOutSecure = Get-Content ($PFileLocation+"pfile.txt") | ConvertTo-SecureString
[PSCredential] $pscredential = New-Object System.Management.Automation.PsCredential($AzureUser,$PassOutSecure)
$TenantID="Tenant ID"

Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $TenantID

Write-Host "Connected to Azure - Checking Resources"

$ActiveWorksheet = $ExcelObject.Worksheets.Add()
$ActiveWorksheet.Name = "ResourceList"
#Add Headers to excel file
$ActiveWorksheet.Cells.Item(1,1) = "Subscription"  
$ActiveWorksheet.Cells.Item(1,2) = "Resource Group"  
$ActiveWorksheet.cells.item(1,3) = "Resource Name" 
$ActiveWorksheet.cells.item(1,4) = "Resource Type" 
$ActiveWorksheet.cells.item(1,5) = "IP Address"
$format = $ActiveWorksheet.UsedRange
$format.Interior.ColorIndex = 19
$format.Font.ColorIndex = 11
$format.Font.Bold = "True" 
$count = 1

$SubscriptionCount = 0
foreach ($Subscription in $SubscriptionNames)
{
    $SubscriptionCount = $SubscriptionCount + 1

    Select-AzSubscription -SubscriptionName $Subscription
  
    $WebApps = Get-AzResource
    foreach ($webApp in $WebApps) {
        $Count = $Count + 1                
        Write-Host $Count        
        $WebAppName = $WebApp.Name
        $WebAppType = $webApp.Type
        $ResourceGroupName = $WebApp.ResourceGroupName
        $ActiveWorksheet.cells.item($Count,1) = $Subscription
        $ActiveWorksheet.cells.item($Count,2) = $ResourceGroupName
        $ActiveWorksheet.cells.item($Count,3) = $WebAppName
        $ActiveWorksheet.cells.item($Count,4) = $WebAppType
        if ($WebAppType -eq "Microsoft.Compute/virtualMachines"){
            $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $WebAppName
            $Nic = $vm.NetworkProfile.NetworkInterfaces[0].Id.Split('/') | select -Last 1
<#
            $publicIpName =  (Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nic).IpConfigurations.PublicIpAddress.Id.Split('/') | select -Last 1
            $publicIpAddress = (Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $publicIpName).IpAddress
#>
            $IpAddress = (Get-AzNetworkInterface -Name $Nic -ResourceGroupName $ResourceGroupName).IpConfigurations.PrivateIPAddress
            $ActiveWorksheet.cells.item($Count,5) = $IpAddress
        }
    }
}
$ExcelObject.ActiveSheet.ListObjects.add(1,$ExcelObject.ActiveSheet.UsedRange,0,1)
$ExcelObject.ActiveSheet.UsedRange.EntireColumn.AutoFit()



$ExcelObject.DisplayAlerts = $false
$ActiveWorkbook.SaveAs($OutputFileName)
$ExcelObject.Workbooks.close()
$ExcelObject.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ExcelObject)
Remove-Variable ExcelObject

