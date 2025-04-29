CLS

$Dictionary = @{'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'}

Function Get-EmailDictionary {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [parameter(mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.Collections.IDictionary]$Dictionary
    )

ForEach ($Box in $Dictionary.GetEnumerator()) {

    $Box_Name = $Box.key.trim()
    $Box_Email = $Box.value.trim()

    $CheckShared = (Get-Mailbox -Identity $Box_Email).PrimarySmtpAddress

    IF ($CheckShared -ne $null) {
        Write-Host -ForegroundColor Yellow "Account Name: `'$Box_Name`' with Email Address: `'$CheckShared`' is a valid email shared mailbox."
    }
    Else {
        Write-Host -ForegroundColor Red "Account Name: `'$Box_Name`' with Email Address: `'$CheckShared`' is NOT a valid email shared mailbox."
    }
}

}#END Function

Get-EmailDictionary -Dictionary $Dictionary

  
