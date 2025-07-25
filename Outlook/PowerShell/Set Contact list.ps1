CLS

Add-Type -assembly "Microsoft.Office.Interop.Outlook" -ErrorAction Stop -ErrorVariable "OutlookError" 
$Outlook = New-Object -comobject Outlook.Application -ErrorAction stop -ErrorVariable "ApplicationError" 
$namespace = $Outlook.GetNameSpace("MAPI") 
$contactObject  = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderContacts) 
$contactList = $contactObject.Items; 

$Birthdate = "11/10/1982 12:00:00 AM"

ForEach ( $name in $contactList ){
    Write-host "Before Birthday="$name.Birthday
}



ForEach ( $name in $contactList ){

    $name.Birthday = $Birthdate

    $name.Save()
    $name.Birthday

}


Write-Host `n


ForEach ( $name in $contactList ){
    Write-host "After Birthday="$name.Birthday
}