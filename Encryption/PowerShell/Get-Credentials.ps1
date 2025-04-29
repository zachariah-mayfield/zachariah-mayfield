CLS

$UserName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$AES_FilePath = "C:\Temp\aes.key"

$Password_FilePath = "C:\Temp\Password.txt"

Function Get-Credentials {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$AES_FilePath,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Password_FilePath,
        [Switch]$DecryptPassword
    )
    Begin {}
    Process {
        IF ($DecryptPassword) {
            $Password = Get-Content $Password_FilePath | ConvertTo-SecureString -Key (Get-Content $AES_FilePath)
            $Decrypt_Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            [pscustomobject]@{
                Password = $Decrypt_Password
            }
        }
        Else {
            # This will retrieve these credentials.
            $EncryptedPassword = Get-Content $Password_FilePath | ConvertTo-SecureString -Key (Get-Content $AES_FilePath)

            # This will store the UserName and Password in the $Credential variable.
            $Credential = New-Object System.Management.Automation.PsCredential($UserName,$EncryptedPassword)
            $Credential
        }
    }
    End {}
}

Get-Credentials -AES_FilePath $AES_FilePath -Password_FilePath $Password_FilePath -UserName $UserName

Get-Credentials -AES_FilePath $AES_FilePath -Password_FilePath $Password_FilePath -UserName $UserName -DecryptPassword
