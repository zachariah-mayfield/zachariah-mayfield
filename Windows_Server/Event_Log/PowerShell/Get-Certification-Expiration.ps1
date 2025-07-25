Function Get-Certification_Expiration {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    Param ()
Begin {
    New-EventLog -LogName xCustomSplunkAlertsx -Source Certificate_Monitor -ErrorAction SilentlyContinue
    $ExpiringCerts = (Get-ChildItem -Path cert: -Recurse -ExpiringInDays 90 | 
    Select PSParentPath, FriendlyName, Subject, SerialNumber, NotAfter, NotBefore, DnsNameList)
}
Process {
    ForEach ($Cert in $ExpiringCerts){
        $Cert_Expire_Date = $Cert.NotAfter | Get-Date
        $Message = [Ordered]@{}

        IF ($Cert_Expire_Date -lt (Get-Date).AddDays(10) ) {
            $Message.add( "Original", ("This Certificate will expire in less than 10 Days."))
            $Message.add( " BlankLine1",(""))}
        ElseIF ($Cert_Expire_Date -lt (Get-Date).AddDays(30) ) {
            $Message.add( "Original", ("This Certificate will expire in less than 30 Days."))
            $Message.add( " BlankLine1",("
"))}
        ElseIF ($Cert_Expire_Date -lt (Get-Date).AddDays(60) ) {
            $Message.add( "Original", ("This Certificate will expire in less than 60 Days."))
            $Message.add( " BlankLine1",("
"))}
        ElseIF ($Cert_Expire_Date -lt (Get-Date).AddDays(90) ) {
            $Message.add( "Original", ("This Certificate will expire in less than 90 Days."))
            $Message.add( " BlankLine1",("
"))}
        $Message.add( "CertificateSerialNumber", ("Certificate Serial Number: " + [String]$Cert.SerialNumber))
        $Message.add( " BlankLine2",("
"))
        $Message.add( "CertificateName", ("Certificate Name: " + [String]$Cert.Subject.trim("CN=").split(",")[0]))
        $Message.add( " BlankLine3",("
"))
        $Message.add( "CertificateLocation", ("Certificate Location: " + [String]$Cert.PSParentPath))
        $Message.add( " BlankLine4",("
"))
        $Message.add( "CertificateDnsNameList", ("Certificate Subject Alternative Name(s): " + [String]$Cert.DnsNameList))
        $Message.add( " BlankLine5",("
"))
        $Message.add( "CertificateCreationDate", ("Certificate Creation Date: " + [String]$Cert.NotBefore))
        $Message.add( " BlankLine6",("
"))
        $Message.add( "CertificateExpireDate", ("Certificate Expires on: " + [String]$Cert.NotAfter))
        $Message.add( " BlankLine7",("
"))
        IF ((Test-Path "D:\Certs\Certificates.txt") -ne $true) {
            $Message.add( "CertificateSpecialRenewalProcess", ("Certificate Special Renewal Process: " + " NO "))
            $Message.add( " BlankLine8",("
"))
        } ELSE {
            $Message.add( "CertificateSpecialRenewalProcess", ("Certificate Special Renewal Process: " + "YES "))
            $Message.add( " BlankLine8",("
"))            
        }
        Write-EventLog -LogName xCustomSplunkAlertsx -Source Certificate_Monitor -EntryType Warning -EventId 7777 -Message $Message.Values 
        #$Message
    }#END ForEach
}#END Process 
END{}
}# END Function

Get-Certification_Expiration
