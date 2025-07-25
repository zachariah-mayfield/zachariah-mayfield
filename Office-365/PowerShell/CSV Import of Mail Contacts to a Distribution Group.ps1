CLS

Function Add-O365ContactToDistributionGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [String]$CSVLocation = "C:\Contacts.csv",
    [int]$CSVRowNumber = "250"
)

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{
####################################################################################################################################################
####################################################################################################################################################


$CSV = Import-Csv $CSVLocation

$Values = @(0..$CSVRowNumber)

ForEach ($V in $Values) {
    
    IF ($CSV[$v] -ne $null) {
        $1 = $CSV[$v].additional_contacts.TrimEnd(";")
        $2 = $1.Split(";")
        $ExternalEmailAddress = $2.Trim()

        ForEach ($Email in $ExternalEmailAddress) {
            
            $CheckEmail = ($Email -as [System.Net.Mail.MailAddress]).Address -eq $Email -and $Email -ne $null

            If ($CheckEmail -eq $true) {

                $Properties = @{'DistroGroupName' = $CSV[$V].name;
                                'Owner'           = $CSV[$V].owned_by;
                                'Contacts'        = $Email}
            }
            Else {
                $Properties = @{'DistroGroupName' = $CSV[$V].name;
                                'Owner'           = $CSV[$V].owned_by;
                                'Contacts'        = $CSV[$V].owned_by}
            
            }

            $Output = New-Object -TypeName psobject -Property $Properties
            Write-Output $Output
            
            If ((Get-MailContact -Anr $Output.Contacts) -or (Get-Recipient -Identity $Output.Contacts)) {
                Write-Host -ForegroundColor Yellow $Output.Contacts 'is a already an Office 365 Contact.'
            }
            Else {
                New-MailContact -Name $Output.Contacts -ExternalEmailAddress $Output.Contacts -Verbose    
            }
            $CheckDG = Get-DistributionGroup -Identity $Output.DistroGroupName -ErrorAction SilentlyContinue
            If ($CheckDG -eq $null) {
                Write-Host -ForegroundColor Cyan "The Distribution Group $Output.DistroGroupName Does not exist. This fucntion is now creating the Distro group."
                $Email = ($Output.DistroGroupName + "@xxxx.com") -replace " ",""
                New-DistributionGroup -Name $Output.DistroGroupName -DisplayName $Output.DistroGroupName -Type Security -PrimarySmtpAddress $Email | Out-Null
            } Else {
                Write-Host -ForegroundColor Cyan "The Distribution Group $Output.DistroGroupName already exists."
            }
            
            $CheckDGM = Get-DistributionGroupMember -Identity $Output.DistroGroupName

            $Owner = (Get-Mailbox -Identity $Output.Owner).UserPrincipalName

            IF ($CheckDGM -match $Output.Contacts){
                Write-Host -ForegroundColor Cyan $Output.Contacts "is already a member of the Distribution Group" $Output.DistroGroupName
            } ELSE {
                Add-DistributionGroupMember -Identity $Output.DistroGroupName -Member $Output.Contacts -BypassSecurityGroupManagerCheck -Verbose -ErrorAction SilentlyContinue
                Add-DistributionGroupMember -Identity $Output.DistroGroupName -Member $Owner -BypassSecurityGroupManagerCheck -Verbose -ErrorAction SilentlyContinue
            }
            Set-DistributionGroup -Identity $Output.DistroGroupName -ManagedBy @{Add="office365roomadmins@xxxx.onmicrosoft.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue | Out-Null
            Set-DistributionGroup -Identity $Output.DistroGroupName -ManagedBy @{Remove="O365Sync.ServiceNow@xxxx.onmicrosoft.com"} -BypassSecurityGroupManagerCheck -ErrorAction SilentlyContinue
            Set-DistributionGroup -Identity $Output.DistroGroupName -RequireSenderAuthenticationEnabled:$false
            Set-DistributionGroup -Identity $Output.DistroGroupName -ManagedBy @{Add="$Owner"} -BypassSecurityGroupManagerCheck -Verbose
        }#END ForEach ($Email in $ExternalEmailAddress)
    }#END IF ($CSV[$v] -ne $null)
}#END ForEach ($V in $Values)


####################################################################################################################################################
####################################################################################################################################################
}#END Process
END {}#END END
}# END Function Add-O365ContactToDistributionGroup


Add-O365ContactToDistributionGroup