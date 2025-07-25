CLS

$SamAccountName = "Enter The Same Account Name"

$User = Get-ADUser -Identity $SamAccountName

$ADgroups = Get-ADPrincipalGroupMembership -Identity $User | where {$_.Name -ne "Domain Users"} #| where {$_.distinguishedName -match "OU=Enterprise Services"}

IF ($ADgroups -ne $null){
	Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADgroups -Confirm:$false
}
