CLS


Function Import-CompanyMailContacts {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
$WarningPreference = "SilentlyContinue"
}#END BEGIN
Process{

$Path = "C:\CompanyRecords1.xlsx"

$Excel = Import-Excel -Path $Path

# This is a loop for $Excel to loop through all of the $Rows in the $Excel items.  
ForEach ($Row in $Excel) {
    
    $CheckContact = $null
    $CheckContact = (Get-MailContact -Identity $Row.ExternalEmailAddress -ErrorAction "SilentlyContinue")

    Try {
        IF ($CheckContact -eq $null) {
            New-MailContact -DisplayName $Row.DisplayName -Name $Row.Name -ExternalEmailAddress $Row.ExternalEmailAddress -Confirm:$false -WarningAction "SilentlyContinue" -ErrorAction "Stop"
            Set-MailContact -Identity $Row.ExternalEmailAddress -EmailAddresses $Row.EmailAddresses
            Write-Output ((("Mail Contact: ") + $Row) + (" is now being created."))
        }
        Else {
            Write-Output ((("Mail Contact: ") + $Row.ExternalEmailAddress) + " already exists.")
        }
    }
    Catch {
        If ($_.Exception.Message -match "already exists"){
            Write-Host -ForegroundColor Yellow $Row.Name ": already exists ERROR"
        }
        ElseIF ($_.Exception.Message -match "is already being used by the proxy addresses or LegacyExchangeDN"){
            Write-Host -ForegroundColor Yellow $Row.Name ": proxy addresses or LegacyExchangeDN ERROR"
        }
        Else {
            $_
        }
    }
}

}#END Process

END{}#END END

}#END Function Import-CompanyMailContacts
