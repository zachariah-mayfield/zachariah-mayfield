


# Variables
$CSV_File_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.csv'

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# Set and store AZ context
$AzureContext = (Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext) 

# Get a list of all xxxxxxxxxxxxxxx Apps
$AzADApps = (Get-AzADApplication | Where-Object {$_.DisplayName -like "*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*"})

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
$AzStorageContext = New-AzStorageContext -StorageAccountName 'xxxxxxxxxxxxxxx' -StorageAccountKey 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$Source_File = ".\$($CSV_File_Name)"
$Container_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
$Folder_Path = 'AzAppEndDates/'
$Destination_Path = $Folder_Path + (Get-Item $Source_File).Name
# Upload and Overwrite File to Azure Data Lake
New-AzDataLakeGen2Item -Context $AzStorageContext -FileSystem $Container_Name -Path $Destination_Path -Source $Source_File -Force
