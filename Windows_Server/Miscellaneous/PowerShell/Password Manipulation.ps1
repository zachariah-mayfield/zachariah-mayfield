CLS

# This is the plain text password stored in the location below.
$PlainTextPassword = "xxxxx" 

# This is converting the password from plain text to a secure string and then outputing it to the location below.
$PlainTextPassword | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\xxxxx\Oracle_Password.txt" -Force

# This is getting the content of that secure string and storing it in a varriable. 
$SecurePassword = Get-Content "C:\xxxxx\Oracle_Password.txt" | ConvertTo-SecureString

# This is converting the variable containg the secure string password to a BSTR.
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)

# This is converting the BSTR converted password to plain text.
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host "Password is: " $Password