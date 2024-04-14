
$installedApps = Get-Content -Path '.\applis.txt'

foreach($appName in $installedApps) {
    try {
        Get-AppxPackage $appName
    } catch {
        Write-Host 'Failed to uninstall: ' + $appName
        Write-Host 'Package may already be removed.'
    }
}

# Disabling services.


Set-Service -Name Spooler -Status stopped -StartupType Disabled
Set-Service -Name DiagTrack -Status stopped -StartupType Disabled
Set-Service -Name ContactData -Status stopped -StartupType Disabled
Set-Service -Name PimIndexMaintenanceSvc_42bf8 -Status stopped -StartupType Disabled
Set-Service -Name DusmSvc -Status stopped -StartupType disable
Set-Service -Name SysMain -Status stopped -StartupType disable
Set-Service -Name MapsBroker -Status stopped -StartupType disable
Set-Service -Name MicrosoftEdgeElevationService -Status stopped -StartupType disable
Set-Service -Name SmsRouter -Status stopped -StartupType disable
Set-Service -Name edgeupdate -Status stopped -StartupType disable
Set-Service -Name edgeupdatem -Status stopped -StartupType disable
Set-Service -Name embeddedmode -Status stopped -StartupType disable
Set-Service -Name DusmSvc -Status stopped -StartupType disable
Set-Service -Name AJRouter -Status stopped -StartupType disable
Set-Service -Name SharedAccess -Status stopped -StartupType disable
Set-Service -Name WpcMonSvc -Status stopped -StartupType disable
Set-Service -Name RemoteRegistry -Status stopped -StartupType disable
Set-Service -Name lmhosts -Status stopped -StartupType disable
Set-Service -Name DoSvc -Status stopped -StartupType AutomaticDelayedStart
Set-Service -Name tzautoupdate -Status stopped -StartupType disable
Set-Service -Name PeerDistSvc -Status stopped -StartupType disable
Set-Service -Name dmwappushsvc -Status Stopped -StartupType Disabled
Remove-Service -Name Fax
Set-Service -Name lfsvc -Status Stopped -StartupType Disabled
Set-Service -Name HvHost -Status Stopped -StartupType Disabled
Set-Service -Name vmickvpexchange -Status Stopped -StartupType Disabled
Set-Service -Name vmicguestinterface -Status Stopped -StartupType Disabled
Set-Service -Name vmicshutdown -Status Stopped -StartupType Disabled
Set-Service -Name vmicheartbeat -Status Stopped -StartupType Disabled
Set-Service -Name vmcompute -Status Stopped -StartupType Disabled
Set-Service -Name vmicvmsession -Status Stopped -StartupType Disabled
Set-Service -Name vmicrdv -Status Stopped -StartupType Disabled
Set-Service -Name vmictimesync -Status Stopped -StartupType Disabled
Set-Service -Name vmicvss -Status Stopped -StartupType Disabled
Set-Service -Name irmon -Status Stopped -StartupType Disabled
Set-Service -Name iphlpsvc -StartupType Automatic
Set-Service -Name IpxlatCfgSvc -StartupType Manual
Set-Service -Name NaturalAuthentication -StartupType Disabled
Set-Service -Name NcdAutoSetup -StartupType Manual
Set-Service -Name NcbService -StartupType Manual
Set-Service -Name netprofm -StartupType Manual
Set-Service -Name NlaSvc -StartupType Automatic
Set-Service -Name CscService -StartupType Disabled
Set-Service -Name SEMgrSvc -StartupType Disabled
Set-Service -Name PhoneSvc -StartupType Disabled
Set-Service -Name RpcLocator -StartupType Disabled
Set-Service -Name SSDPSRV -StartupType Disabled
Set-Service -Name UsoSvc -Status Stopped -StartupType Manual
Set-Service -Name spectrum -Status Stopped -StartupType Manual
Set-Service -Name WinRM -Status Stopped -StartupType Disabled
Set-Service -Name workfolderssvc -Status Stopped -StartupType Disabled
Set-Service -Name WwanSvc -Status Stopped -StartupType Disabled