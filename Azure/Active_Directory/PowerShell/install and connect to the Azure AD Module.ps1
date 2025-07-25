CLS



$KEY = "KEY"

$User = "O365Sync.ServiceNow@Company.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String $KEY -AsPlainText -Force
$UserCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

#This installs the Azure AD Module
# Install-Module MSOnline -Confirm:$false -Force 

#This imports the Azure AD Module
# Import-Module -Name MSOnline -Force

#This connects to Azure AD
Connect-MsolService -Credential $UserCredential