#Constant Variables 
$OutputFile = "LastLogonDate.csv"   #The CSV Output file that is created, change for your purposes 
 
#Main 
Function Main { 
 
    #Remove all existing Powershell sessions 
    Get-PSSession | Remove-PSSession 
     
    #Call ConnectTo-ExchangeOnline function with correct credentials 
    #ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password             
    ConnectTo-ExchangeOnline 

    #Prepare Output file with headers 
    Out-File -FilePath $OutputFile -InputObject "UserPrincipalName,LastLogonDate" -Encoding UTF8 

    #No input file found, gather all mailboxes from Office 365 
    $objUsers = get-mailbox -ResultSize Unlimited | select UserPrincipalName 
     
    #Iterate through all users     
    Foreach ($objUser in $objUsers) 
    {     
        #Connect to the users mailbox 
        $objUserMailbox = get-mailboxstatistics -Identity $($objUser.UserPrincipalName) | Select LastLogonTime 
         
        #Prepare UserPrincipalName variable 
        $strUserPrincipalName = $objUser.UserPrincipalName 
         
        #Check if they have a last logon time. Users who have never logged in do not have this property 
        if ($objUserMailbox.LastLogonTime -eq $null) 
        { 
            #Never logged in, update Last Logon Variable 
            $strLastLogonTime = "Never Logged In" 
        } 
        else 
        { 
            #Update last logon variable with data from Office 365 
            $strLastLogonTime = $objUserMailbox.LastLogonTime 
        } 
         
        #Output result to screen for debuging (Uncomment to use) 
        #write-host "$strUserPrincipalName : $strLastLogonTime" 
         
        #Prepare the user details in CSV format for writing to file 
        $strUserDetails = "$strUserPrincipalName,$strLastLogonTime" 
         
        #Append the data to file 
        Out-File -FilePath $OutputFile -InputObject $strUserDetails -Encoding UTF8 -append 
    } 
     
    #Clean up session 
    Get-PSSession | Remove-PSSession 
} 
 
############################################################################### 
# 
# Function ConnectTo-ExchangeOnline 
# 
# PURPOSE 
#    Connects to Exchange Online Remote PowerShell using the tenant credentials 
# 
# INPUT 
#    Tenant Admin username and password. 
# 
# RETURN 
#    None. 
# 
############################################################################### 
function ConnectTo-ExchangeOnline 
{    
    $cred = Get-Credential
     
 
    $o365 = New-PsSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -AllowRedirection -Authentication Basic

    #Import the session 
    #Import-PSSession $Session -AllowClobber | Out-Null 
    Import-PsSession $o365
} 
 
 
# Start script 
. Main