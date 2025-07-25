CLS

function Start-lhstationconfig_update {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param ()
Begin{
    # This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
    $Global:FormatEnumerationLimit=-1

    #This will suppress all warnings.
    $WarningPreference = 'SilentlyContinue'
}#END Begin
Process {
    TRY {
        Stop-Service SSInstallManager -Verbose -Confirm:$false -NoWait -Force -ErrorAction Stop
    }
    Catch {
        $_
    }
    TRY {
        Remove-Item 'C:\Program Files\Radiant\RTSSendFile.tmp' -Force -ErrorAction Stop
    }
    Catch {
        $_
    }
    TRY {
        Remove-Item 'C:\Program Files\Radiant\Lighthouse\Data\RTSHistory.xml' -Force -ErrorAction Stop
    }
    Catch {
        $_
    }
    TRY {
        Start-Service SSInstallManager -Confirm:$false -ErrorAction Stop
    }
    Catch {
        $_
    }
}#END Process
END {}#END END
}#END Function
