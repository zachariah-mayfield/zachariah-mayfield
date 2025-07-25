CLS


Add-Type -assembly "Microsoft.Office.Interop.Outlook" -ErrorAction Stop -ErrorVariable "OutlookError" 

$Outlook = New-Object -comobject Outlook.Application -ErrorAction stop -ErrorVariable "ApplicationError" 

$namespace = $Outlook.GetNameSpace("MAPI") 

$contactObject  = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderContacts) 

$contactList = $contactObject.Items; 


$contactList
