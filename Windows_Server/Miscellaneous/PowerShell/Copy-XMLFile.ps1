CLS



Function Copy-XMLFile {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
    [Parameter()]
    [String]$LocationAndFileName = "C:\xxx_1.XML",
    [Parameter()]
    [String]$VersionNumber = "xxxxx",
    [Parameter()]
    [String]$UpgradeFileName = "/xxxx",
    [Parameter()]
    [Switch]$Patch,
    [Parameter()]
    [Switch]$Upgrade
    )
Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}#END BEGIN
Process{


IF ($Patch) {

TRY {

[XML]$XML = ("
<DownloadManifest>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/$VersionNumber.exe</RemoteURL>
        <RelativePath>$VersionNumber.exe</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/InstallManifest.xml</RemoteURL>
        <RelativePath>InstallManifest.xml</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/ExternalUpdate.bat</RemoteURL>
        <RelativePath>ExternalUpdate.bat</RelativePath>
    </File>
</DownloadManifest>
") 

$XML.Save($LocationAndFileName)

}#END TRY

Catch {

Write-Host -ForegroundColor Yellow "The was an error Creating/Saving the XML FILE"

}#END Catch

}#END IF ($Patch)

If ($Upgrade) {

TRY {

[XML]$XML = @("
<DownloadManifest>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/ExternalUpdate.bat</RemoteURL>
        <RelativePath>ExternalUpdate.bat</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/InstallManifest.xml</RemoteURL>
        <RelativePath>InstallManifest.xml</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/LaunchFS.cmd</RemoteURL>
        <RelativePath>LaunchFS.cmd</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/Postupgrade.exe</RemoteURL>
        <RelativePath>Postupgrade.exe</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber$UpgradeFileName$VersionNumber`_Upgrade.msi</RemoteURL>
        <RelativePath>$UpgradeFileName$VersionNumber`_Upgrade.msi</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/Unattended.reg</RemoteURL>
        <RelativePath>Unattended.reg</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/UpdateHandler.exe</RemoteURL>
        <RelativePath>UpdateHandler.exe</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/EndScUtil.exe</RemoteURL>
        <RelativePath>EndScUtil.exe</RelativePath>
    </File>
    <File>
        <RemoteURL>http://XXX/$VersionNumber/ntrights.exe</RemoteURL>
        <RelativePath>ntrights.exe</RelativePath>
    </File>
</DownloadManifest>")

$XML.Save($LocationAndFileName)

}#END TRY

Catch {

Write-Host -ForegroundColor Yellow "The was an error Creating/Saving the XML FILE"

}#END Catch

}#END If ($Upgrade)


}#END Process
END {}#END END
}# END Function 
