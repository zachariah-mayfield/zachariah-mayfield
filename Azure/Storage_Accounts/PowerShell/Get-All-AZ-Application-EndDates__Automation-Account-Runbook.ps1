# Create Azure Automation account and name it = xxxxxxxxxxx
# Request Azure access of 'Global Reader'
# Request Azure access of 'Application Developer Role'
# Request Azure access of 'Contributor Role' in Subscription 'xxxxxxxxxxxxxxx'
# Request Azure access of 'highest level for inheritance to all subscriptions' 
# How to start Azure Storage Explorer if Cert error
# Start "C:\Program Files (x86)\Microsoft Azure Storage Explorer\StorageExplorer.exe" --ignore-certificate-errors

# Variables
$CSV_File_Name = 'xxxxxxxEndDates.csv'

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# -WarningAction 'Ignore'
# TenantId 'xxxxxxxxxxxxxxxxxx' contains more than one active subscription. 
# First one will be selected for further use. To select another subscription, use Set-AzContext.
###
# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity -WarningAction 'Ignore').context <#'xxxxxxxxxxxxxxxxxx'#>

# Subscription = 'xxxxxxxxxxxxxxxxxxx' 
# Set and store AZ context
$AzureContext = (Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext) 

# Get a list of all xxxxxxxxx AZ Apps
$AzADApps = (Get-AzADApplication | Where-Object {$_.DisplayName -like "*xxxxxxxxxxProd*"}) # xxxxxxxxxxWProd  xxxxx

ForEach ($AzADApp in $AzADApps) {
	$AzADApp_Cred = (Get-AzADAppCredential -ObjectId $AzADApp.ObjectId)
	$AzADApp_DisplayName = ($AzADApp.DisplayName | Out-String).Trim()
	$AzADApp_ObjectId = ($AzADApp.ObjectId | Out-String).Trim()
	$AzADApp_EndDate = ($AzADApp_Cred.EndDate | Out-String).Trim()
	$Object = New-Object PSObject -Property @{
               DisplayName = $AzADApp_DisplayName
			   ObjectId = $AzADApp_ObjectId
               EndDate = $AzADApp_EndDate
	}
	$Object | Select-Object -Property DisplayName, ObjectId, EndDate | Export-Csv -Path ".\$($CSV_File_Name)" -NoTypeInformation -Append -Force
}
# Check File Content
#Get-Content -Path .\AzADApp_EndDates.csv

# Set AZ Storeage Context
$AzStorageContext = New-AzStorageContext -StorageAccountName 'xxxxxxxxxxxxxxxx' -StorageAccountKey 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$Source_File = ".\$($CSV_File_Name)"
$Container_Name = "XXXXteam" 
$Folder_Path = 'Admin/XXXX/'
$Destination_Path = $Folder_Path + (Get-Item $Source_File).Name
# Upload and Overwrite File to Azure Data Lake
New-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container_Name -Path $Destination_Path -Source $Source_File -Force

