
function Upload-AzureBlob {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,

        [Parameter(Mandatory=$true)]
        [string]$ContainerName,

        [Parameter(Mandatory=$true)]
        [string]$BlobFilePath,

        [Parameter(Mandatory=$true)]
        [string]$BlobName,

        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )

    try {
        # Connect to Azure account
        Connect-AzAccount

        # Retrieve Storage Account Key
        $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]

        # Create Storage Context
        $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey

        # Upload Blob
        $blobUpload = Set-AzStorageBlobContent -File $BlobFilePath -Container $ContainerName -Blob $BlobName -Context $context

        Write-Host "Upload successful: $($blobUpload.CloudBlob.Uri)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Error uploading blob: $_"
    }
}
  
