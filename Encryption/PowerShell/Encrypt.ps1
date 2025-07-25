CLS

$UserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Password = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$AES_FilePath = "C:\Temp"
$AES_FileName = "aes"

$Password_FilePath = "C:\Temp"
$Password_FileName = "Password"

Function Encrypt-Credentials {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$AES_FilePath,
        [Parameter(Mandatory=$true)]
        [String]$AES_FileName,
        [System.IO.FileInfo]$Password_FilePath,
        [Parameter(Mandatory=$true)]
        [String]$Password_FileName
    )
    Begin {
        #####################################################################################################################################
        $New_AES_File = "$AES_FilePath\$AES_FileName.key"
        IF ((Test-Path $New_AES_File) -ne $true) {
            Write-Host -ForegroundColor Yellow "AES File: " $AES_FilePath " Does not exist, so it is now being created."
            New-Item -ItemType "directory" -Path $AES_FilePath -Force
        }
        #####################################################################################################################################
        $New_Password_File = "$Password_FilePath\$Password_FileName.txt"
        IF ((Test-Path $New_Password_File) -ne $true) {
            Write-Host -ForegroundColor Yellow "Password File: " $Password_FilePath " Does not exist, so it is now being created."
            New-Item -ItemType "directory" -Path $Password_FilePath -Force
        }
        #####################################################################################################################################
        # This will generate a 256-bit AES encryption key and use that key to access our password file. 
        # The purpose of this is so that we can get around the limitation of the user account you are using to create the password file,
        # is the same account that must be used to open the password file. (Windows Data Protection API)
        $Key = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        $Key | Out-File $New_AES_File
    }
    Process {
        $PlainPassWord = ConvertTo-SecureString -String $Password -AsPlainText -Force 
        # The -key parameter to specify that we want to use a key and input the location of the key file. 
        # Then we create the password file where the KEY will unlock the file and not the User.
        $PlainPassWord | ConvertFrom-SecureString -key (Get-Content $New_AES_File) | Set-Content $New_Password_File

        # This will retrieve these credentials.
        $EncryptedPassword = Get-Content $New_Password_File | ConvertTo-SecureString -Key (Get-Content $New_AES_File)

        # This will store the UserName and Password in the $Credential variable.
        $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
    }
    End {Write-Host -ForegroundColor Cyan "The UserName: " $UserName " Password has been encrypted, and stored in the file path: " $New_Password_File 
         Write-Host -ForegroundColor Cyan "it can be accessed by the AES encryption Key file: " $New_AES_File " using the Get-Credentials PS function."}
}

Encrypt-Credentials -UserName $UserName -Password $Password -AES_FilePath $AES_FilePath -AES_FileName $AES_FileName -Password_FilePath $Password_FilePath -Password_FileName $Password_FileName
