CLS





try { 
    Add-Type -assembly "Microsoft.Office.Interop.Outlook" -ErrorAction Stop -ErrorVariable "OutlookError" 
    $Outlook = New-Object -comobject Outlook.Application -ErrorAction stop -ErrorVariable "ApplicationError" 
    $namespace = $Outlook.GetNameSpace("MAPI") 
    $contactObject  = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderContacts) 
    $contactList = $contactObject.Items; 
} 
         
# Catch all other exceptions thrown by one of those commands 
catch { 
    $OutlookError
    $ApplicationError 
        }

     
ForEach ( $name in $contactList ) {
    $props = @{
                'JobTitle' = $name.JobTitle; 
                'FullName' = $name.FullName; 
                'FirstName' = $name.FirstName;
                'LastName' = $name.LastName; 
                'Email Address' = $name.Email1Address; 
                'Mobile' = $name.MobileTelephoneNumber; 
                }     

    $object = New-Object -TypeName PsObject -Property $props 
    Write-Output $object 
# You may find more contact field details from this link => : http://msdn.microsoft.com/en-us/library/ee160254(v=exchg.80).aspx 
} 
     