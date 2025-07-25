    $Tenant_ID = 'xxxxxxxxxxxxxxxxxxxxxxx'
    $Subscription_ID = 'xxxxxxxxxxxxxxxxxxxxxxx'
    $Azure_PassWord = (Get-StoredCredential -Target 'Domain' -Type Generic -AsCredentialObject).Password
    $UserName = "$($env:USERNAME)@Google.com"
    $EncryptedPassword = ConvertTo-SecureString $Azure_PassWord -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
    $AzureConnection = (Connect-AzAccount -Credential $Credential -Tenant $Tenant_ID -Subscription $Subscription_ID -WarningAction 'Ignore').context 
    $AzureContext = (Set-AzContext -SubscriptionName $Subscription_ID -DefaultProfile $AzureConnection) 
    $Application_ID = 'xxxxxxxxxxxxxxxxxxxxxxx'

    $PFX_FileName = "xxxxxxxxxxxxxxxxxxxxxxx"
    $Cert_Password = "xxxxxxxxxxxxxxxxxxxxxxx"
    $Cert_Password = ConvertTo-SecureString -String $Cert_Password -Force -AsPlainText
    $CurrentDate = Get-Date
    $EndDate = $CurrentDate.AddYears(10)

    $certificatePath =  "C:\FilePath\Certificates\Certs\$($PFX_FileName).pfx" # OR Get-ChildItem -Path cert:\localmachine\my\$($Certificate_Thumbprint)
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePath, $Cert_Password)
    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
    $Azure_App_Registration = Get-AzADApplication -ApplicationId $Application_ID -DefaultProfile $AzureContext

    New-AzADAppCredential -ApplicationObject $Azure_App_Registration -CertValue $keyValue -EndDate $EndDate -StartDate $CurrentDate 

    Connect-AzAccount -Subscription $Subscription_ID -ApplicationId $Azure_App_Registration.AppId -Tenant $Tenant_ID -CertificateThumbprint $cert.Thumbprint | Out-Null

    Get-AzADAppCredential -ApplicationId $Azure_App_Registration.AppId | Where-Object {$_.DisplayName -match "CN=xxxxxxxxxxxxxxxxxxxxxxx"}
