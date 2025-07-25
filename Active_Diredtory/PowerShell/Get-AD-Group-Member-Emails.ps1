CLS

$DistinguishedName = ("CN=OU=Group,OU=Enterprise")

Function Get-AD_Group_Member_Emails {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$DistinguishedName
    )
Begin {
    $FormatEnumerationLimit="0"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
Process {
    $Group_Members = (Get-ADGroupMember -Identity $DistinguishedName)
    ForEach ($Member in $Group_Members) {
        $SamAccountName = $Member.SamAccountName
        $User = (Get-ADUser -Identity $SamAccountName)
        $Object = New-Object -TypeName PSObject
        $Object | Add-Member -MemberType NoteProperty -Name ”Name” -Value ($User.Name)
        $Object | Add-Member -MemberType NoteProperty -Name ”SamAccountName” -Value ($User.SamAccountName)
        $Object | Add-Member -MemberType NoteProperty -Name ”Email” -Value ($User.UserPrincipalName)
        
        $Object
    }
}
END {}
}#END Function Get-AD_Group_Member_Emails

