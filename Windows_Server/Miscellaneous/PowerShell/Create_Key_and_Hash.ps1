
# Creating AES key with random data and export to file
$KeyFile = "D:\xxxx\NewAES.key"
$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | Out-File $KeyFile


# Creating SecureString object
$PasswordFile = "D:\xxxx\NewHash.txt"
$KeyFile =  "D:\xxxx\NewAES.key"
$Key = Get-Content $KeyFile
$Password = "xxxx" | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -Key $Key | Out-File $PasswordFile


