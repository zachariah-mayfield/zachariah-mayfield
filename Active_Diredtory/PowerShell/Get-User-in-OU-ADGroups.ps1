CLS
$OU = "OU=xxxxx,OU=Enterprise Services"

$SamAccountName = "xxxxxx"

Function Get-User_in_OU_ADGroups {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String]$SamAccountName,
        [Parameter(Mandatory=$true)]
        [String]$OU

    )
Begin {
    $User = Get-ADUser -Identity $SamAccountName
}
Process {
    $XXXXX_ADgroups = Get-ADPrincipalGroupMembership -Identity $User | where {$_.distinguishedName -match $OU}
    $XXXXX_ADgroups
}
END {}
}

Get-User_in_OU_ADGroups -SamAccountName $SamAccountName
