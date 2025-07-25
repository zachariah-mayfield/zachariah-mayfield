CLS

$AES_FilePath = "C:\Temp\aes.key"

$Password_FilePath = "C:\Temp\Password.txt"

Function Decrypt-Corp_Credentials {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$AES_FilePath,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Password_FilePath
    )
    Begin {}
    Process {
        $Password = Get-Content $Password_FilePath | ConvertTo-SecureString -Key (Get-Content $AES_FilePath)
        $Decript_Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        [pscustomobject]@{
            Password = $Decript_Password
        }
    }
    END {}
}
