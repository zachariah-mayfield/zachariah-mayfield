Clear-Host 
$FormatEnumerationLimit=-1
#region IDs
#############################################################################################################################################################################################
    # Azure Active Directory -> App registrations -> Select Account -> Application (client) ID
    $Client_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Directory (tenant) ID
    # $Tenant_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory -> App registrations -> Select Account -> Certificates & secrets -> Client secrets -> "Secret Value"  ((NOT Secret ID))
    $Secret_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Subscription_Name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # $Resource_Group = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    # Azure Active Directory App Registrations - This is where the Certificate is stored in Azure.
    # $App_Registration_Name =  'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#############################################################################################################################################################################################
#endregion IDs

#region Dates
$CurrentDate = Get-Date
$EndDate = $CurrentDate.AddYears(10)
$NotAfter = $EndDate.AddYears(10)
#endregion Dates

#region Create the self signed cert
$Certificate_Name = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Cert_Password = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Cert_Password = ConvertTo-SecureString -String $Cert_Password -Force -AsPlainText
$Certificate_Thumbprint = (New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName $Certificate_Name -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $NotAfter).Thumbprint
Export-PfxCertificate -cert "cert:\localmachine\my\$Certificate_Thumbprint" -FilePath "C:\Users\xxxxxxxxxx\OneDrive - xxxxxxxxx\Certificates\Certs\$($Certificate_Name).pfx" -Password $Cert_Password
#endregion Create the self signed cert

#region Load the certificate
$certificatePath =  "C:\Users\xxxxxxx\Certificates\Certs\$($Certificate_Name).pfx" #Get-ChildItem -Path cert:\localmachine\my\$($Certificate_Thumbprint)
$cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePath, $Cert_Password)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
#endregion Load the certificate

#region Initial Connection to Azure to perform the prerequisite tasks
$Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
$UserName = "$($env:USERNAME)@xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
$AzureConnection = (Connect-AzAccount -Credential $Credential -Tenant $Tenant_ID -Subscription $Subscription_ID -WarningAction 'Ignore').context
$AzureContext = (Set-AzContext -SubscriptionName $Subscription_ID -DefaultProfile $AzureConnection) 
#endregion Initial Connection to Azure to perform the prerequisite tasks

$Azure_App_Registration = Get-AzADApplication -ApplicationId $Application_ID -DefaultProfile $AzureContext

New-AzADAppCredential -ApplicationObject $Azure_App_Registration -CertValue $keyValue -EndDate $EndDate -StartDate $CurrentDate 

Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Azure_App_Registration.AppId -Tenant $Tenant_ID -CertificateThumbprint $cert.Thumbprint | Out-Null

Get-AzADAppCredential -ApplicationId $Azure_App_Registration.AppId | Where-Object {$_.DisplayName -match "CN=$($Certificate_Name)"}
