CLS

###  GET  ### HOST record with cookies

#This example demonstrates the use of cookies(ibapauth)#
Ignore-SelfSignedCerts
$url = "https://127.0.0.1/wapi/v2.7/record:host?_return_as_object=1"
$pwd = ConvertTo-SecureString "Infoblox" -AsPlainText -Force
$creds = New-Object Management.Automation.PSCredential ('admin', $pwd)
Invoke-RestMethod -Uri $url -Method GET -Credential $creds -SessionVariable authcookie
#You can re-use the authcookie in subsequent API calls#
Invoke-RestMethod -Uri $url -Method GET -WebSession $authcookie
