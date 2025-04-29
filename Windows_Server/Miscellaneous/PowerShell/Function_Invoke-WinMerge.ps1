Clear-Host

Function Invoke-WinMergeEXE {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Left_Content,
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Right_Content,
        [Parameter(Mandatory=$true,HelpMessage='Enter the Disk Location and Name of your OutputFile Parameter FILE EXTENSION MUST BE CSV!')]
        [System.IO.FileInfo]$OutputFile
    )
    Begin {
        $WinMergeEXE = [System.IO.Path]::Combine($env:programfiles, "WinMerge", "WinMergeU.EXE")
        IF (!(Test-Path $WinMergeEXE)) {
            # This will use Chocolatey to install WinMerge.EXE
            # Or you can go to GitHub and install it manually for the latest version.
            choco install winmerge --pre 
        }
        IF ($OutputFile -notlike "*.CSV") {
            Write-Host -ForegroundColor Cyan "Wrong File Extension $OutputFile is not a CSV File."
            Exit
        }
        <#Specifies the folder, file or project file to open on the left side.#>,<#Specifies the folder, file or project file to open on the right side.#>
        $WinMerge_Args = $Left_Content, $Right_Content
        <#Starts WinMerge as a minimized window. This option can be useful during lengthy compares.#>
        $WinMerge_Args += ' -minimize '
        <#Does not present an interactive prompt to the user.#>
        $WinMerge_Args += ' -noninteractive '
        <#Prevents WinMerge from adding any path to the Most Recently Used (MRU) list. External applications should not add paths to the MRU list in the Select Files or Folders dialog.#>
        $WinMerge_Args += ' -u '
        <# Compares all files in all subfolders (recursive compare). Unique folders (occurring only on one side) are listed in the compare result as separate items.#>
        $WinMerge_Args += ' -r '
        <#to specify the path where you want to output the output of the report. This feature is not riding on the document.#>
        $WinMerge_Args += ' -or '
        <#This is where the CSV file that WinMerge.EXE generates will be located.#>
        $WinMerge_Args += $OutputFile
    }
    Process {
        IF (!(Test-Path $OutputFile)) {
            # This will run the WinMerge.EXE with the supplied arguments.
            Start-Process $WinMergeEXE -ArgumentList $WinMerge_Args
            while (!(Test-Path $OutputFile)) {
                Write-Host -ForegroundColor Cyan "Waiting for WinMerge.EXE to finish comparing the contents and compiling the CSV file."
                Start-Sleep -Seconds 5
            }
        }
        Else {
            Write-Host -ForegroundColor Cyan "$OutputFile already exists. Exiting script. Next time enter a File Name that doesen't exist."
            Exit
        }
    }
    End {
        # This will open the new WinMerge.EXE generated CSV file.
        Start-Process -FilePath $OutputFile
    }#END
}# Function END
