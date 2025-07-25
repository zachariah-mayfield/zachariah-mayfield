##The first two lines of the script load the CSOM model:
Add-Type -Path "C:\Users\{username}\downloads\Microsoft.SharePointOnline.CSOM.16.1.5026.1200\lib\net45\Microsoft.SharePoint.Client.dll"

Add-Type -Path "C:\Users\{username}\downloads\Microsoft.SharePointOnline.CSOM.16.1.5026.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll"

$webUrl = 'https://Company.sharepoint.com/sites/sitename'
$username = Read-Host -Prompt "Enter or paste the site collection administrators full O365 email, for example, name@domain.onmicrosoft.com" 
$password = Read-Host -Prompt "Password for $username" -AsSecureString

[Microsoft.SharePoint.Client.ClientContext]$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($webUrl)
$clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password)

# To apply the script to the site collection level, uncomment the next two lines.
$site = $clientContext.Site; 
$featureguid = new-object System.Guid "xxxxxxxxxxxxxxxxxxxxxx"

# To apply the script to the website level, uncomment the next two lines, and comment the preceding two lines.
#$site = $clientContext.Web;
#$featureguid = new-object System.Guid "xxxxxxxxxxxxxxxxxxxxxxxxx" 

# To turn off the new UI by default in the new site, uncomment the next line.
#$site.Features.Add($featureguid, $true, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None);

# To re-enable the option to use the new UI after having first disabled it, uncomment the next line.
# and comment the preceding line.
#$site.Features.Remove($featureguid, $true);

$clientContext.ExecuteQuery();