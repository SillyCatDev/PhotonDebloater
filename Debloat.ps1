
$installedApps = Get-Content -Path '.\applis.txt'
function Debloat {
    Clear-Host
    Write-Host "The script will now debloat windows." -ForegroundColor Green
    Write-Host "◦ Step 1: Remove UWP Garbage." -ForegroundColor Green
    $yesnouwp = Read-Host "This portion will ATTEMPT to remove useless UWP Apps. A window will appear prompting you to select apps to keep and apps to remove. Would you like to continue? [Selecting No will take you to modify services section ] (Y/N)"
    switch ($yesnouwp) {
        "y" {AppSelectionForm}
        "n" {
            Clear-Host
            DisableServicesConsent
            }
    }
}

function OOSU {
    Write-Host "Downloading O&O ShutUp10++ from https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe..."
    Invoke-WebRequest -Uri https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe -OutFile $ENV:temp\\OOSU10.exe
    Write-Host "Success! Running OO ShutUp10++" -ForegroundColor Green
    Start-Process $ENV:temp\\OOSU10.exe -ArgumentList '.\ooshutup10-configs.cfg'
    Write-Host "Success! Proceeding to main menu." -ForegroundColor Green
    Clear-Host && MainMenu
}

function AppSelectionForm {
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    # Initialize all the form objs that will be used.
    $form = New-Object System.Windows.Forms.Form
    $label = New-Object System.Windows.Forms.Label
    $button1 = New-Object System.Windows.Forms.Button
    $button2 = New-Object System.Windows.Forms.Button
    $selectionBox = New-Object System.Windows.Forms.CheckedListBox 
    $loadingLabel = New-Object System.Windows.Forms.Label
    $onlyInstalledCheckBox = New-Object System.Windows.Forms.CheckBox
    $checkUncheckCheckBox = New-Object System.Windows.Forms.CheckBox
    $initialFormWindowState = New-Object System.Windows.Forms.FormWindowState

    $global:selectionBoxIndex = -1

    # saveButton eventHandler
    $handler_saveButton_Click= 
    {
        $global:SelectedApps = $selectionBox.CheckedItems

        # Create file that stores selected apps if it doesn't exist
        if (!(Test-Path "$PSScriptRoot//Run//SelectedAppsList.txt")) {
            $null = New-Item "$PSScriptRoot//Run//CustomAppsList.txt"
        } Set-Content -Path "$PSScriptRoot///Run//CustomAppsList.txt" -Value $global:SelectedApps
        $form.Close()
    }

    # cancelBtnHandler
    $handler_cancelButton_Click= 
    {
        $form.Close()
    }

    $selectionBox_SelectedIndexChanged= 
    {
        $global:selectionBoxIndex = $selectionBox.SelectedIndex
    }

    $selectionBox_MouseDown=
    {
        if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            if([System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::Shift) {
                if($global:selectionBoxIndex -ne -1) {
                    $topIndex = $global:selectionBoxIndex

                    if ($selectionBox.SelectedIndex -gt $topIndex) {
                        for(($i = ($topIndex)); $i -le $selectionBox.SelectedIndex; $i++){
                            $selectionBox.SetItemChecked($i, $selectionBox.GetItemChecked($topIndex))
                        }
                    }
                    elseif ($topIndex -gt $selectionBox.SelectedIndex) {
                        for(($i = ($selectionBox.SelectedIndex)); $i -le $topIndex; $i++){
                            $selectionBox.SetItemChecked($i, $selectionBox.GetItemChecked($topIndex))
                        }
                    }
                }
            }
            elseif($global:selectionBoxIndex -ne $selectionBox.SelectedIndex) {
                $selectionBox.SetItemChecked($selectionBox.SelectedIndex, -not $selectionBox.GetItemChecked($selectionBox.SelectedIndex))
            }
        }
    }

    $check_All=
    {
        for(($i = 0); $i -lt $selectionBox.Items.Count; $i++){
            $selectionBox.SetItemChecked($i, $checkUncheckCheckBox.Checked)
        }
    }

    $load_Apps=
    {
        # Correct the initial state of the form to prevent the .Net maximized form issue
        $form.WindowState = $initialFormWindowState

        # Reset state to default before loading appslist again
        $global:selectionBoxIndex = -1
        $checkUncheckCheckBox.Checked = $False

        # Show loading indicator
        $loadingLabel.Visible = $true
        $form.Refresh()

        # Clear selectionBox before adding any new items
        $selectionBox.Items.Clear()

        # Set filePath where Appslist can be found
        $installedApps = "$PSScriptRoot/applis.txt"
        $listOfApps = ""

        if ($onlyInstalledCheckBox.Checked -and ($global:wingetInstalled -eq $true)) {
            # Attempt to get a list of installed apps via winget, times out after 10 seconds
            $job = Start-Job { return winget list --accept-source-agreements --disable-interactivity }
            $jobDone = $job | Wait-Job -TimeOut 10

            if (-not $jobDone) {
                # Show error that the script was unable to get list of apps from winget
                [System.Windows.MessageBox]::Show('Unable to load list of installed apps via winget, some apps may not be displayed in the list.','Error','Ok','Error')
            }
            else {
                # Add output of job (list of apps) to $listOfApps
                $listOfApps = Receive-Job -Job $job
            }
        }

        # Go through appslist and add items one by one to the selectionBox
        foreach ($app in (Get-Content -Path $installedApps | Select-Object -Skip 4 | Where-Object { $_ -notmatch '^\s*$' } )) { 
            $appChecked = $true

            # Remove first # if it exists and set AppChecked to false
            if ($app.StartsWith('#')) {
                $app = $app.TrimStart("#")
                $appChecked = $false
            }
            # Remove any comments from the Appname
            if (-not ($app.IndexOf('#') -eq -1)) {
                $app = $app.Substring(0, $app.IndexOf('#'))
            }
            # Remove any remaining spaces from the Appname
            if (-not ($app.IndexOf(' ') -eq -1)) {
                $app = $app.Substring(0, $app.IndexOf(' '))
            }

            $appString = $app.Trim('*')

            # Make sure appString is not empty
            if ($appString.length -gt 0) {
                if ($onlyInstalledCheckBox.Checked) {
                    # onlyInstalledCheckBox is checked, check if app is installed before adding it to selectionBox
                    if ($listOfApps -like ("* " + $appString + " *")) {
                        $installed = "installed"
                    }
                    elseif (($appString -eq "Microsoft.Edge") -and ($listOfApps -like "* XPFFTQ037JWMHS *")) {
                        $installed = "installed"
                    }
                    else {
                        $installed = Get-AppxPackage -Name $app
                    }

                    if ($installed.length -eq 0) {
                        # App not installed.
                        continue
                    }
                }

                # add app to selection lis
                $selectionBox.Items.Add($appString, $appChecked) | Out-Null
            }
        }
        
        # Hide loading indicator
        $loadingLabel.Visible = $False
    }

    $form.Text = ""
    $form.Name = "appSelectionForm"
    $form.DataBindings.DefaultDataSourceUpdateMode = 0
    $form.ClientSize = New-Object System.Drawing.Size(400,502)
    $form.MaximizeBox = $True

    $button1.TabIndex = 4
    $button1.Name = "saveButton"
    $button1.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $button1.UseVisualStyleBackColor = $True
    $button1.Text = "Confirm"
    $button1.Location = New-Object System.Drawing.Point(27,472)
    $button1.Size = New-Object System.Drawing.Size(75,23)
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.add_Click($handler_saveButton_Click)

    $form.Controls.Add($button1)

    $button2.TabIndex = 5
    $button2.Name = "cancelButton"
    $button2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $button2.UseVisualStyleBackColor = $True
    $button2.Text = "Cancel"
    $button2.Location = New-Object System.Drawing.Point(129,472)
    $button2.Size = New-Object System.Drawing.Size(75,23)
    $button2.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2.add_Click($handler_cancelButton_Click)

    $form.Controls.Add($button2)

    $label.Location = New-Object System.Drawing.Point(13,5)
    $label.Size = New-Object System.Drawing.Size(400,14)
    $Label.Font = 'Microsoft Sans Serif,8'
    $label.Text = 'Check apps that you wish to remove, uncheck apps that you wish to keep'

    $form.Controls.Add($label)

    $loadingLabel.Location = New-Object System.Drawing.Point(16,46)
    $loadingLabel.Size = New-Object System.Drawing.Size(300,418)
    $loadingLabel.Text = 'Loading apps...'
    $loadingLabel.BackColor = "White"
    $loadingLabel.Visible = $false

    $form.Controls.Add($loadingLabel)

    $onlyInstalledCheckBox.TabIndex = 6
    $onlyInstalledCheckBox.Location = New-Object System.Drawing.Point(230,474)
    $onlyInstalledCheckBox.Size = New-Object System.Drawing.Size(150,20)
    $onlyInstalledCheckBox.Text = 'Only show installed apps'
    $onlyInstalledCheckBox.add_CheckedChanged($load_Apps)

    $form.Controls.Add($onlyInstalledCheckBox)

    $checkUncheckCheckBox.TabIndex = 7
    $checkUncheckCheckBox.Location = New-Object System.Drawing.Point(16,22)
    $checkUncheckCheckBox.Size = New-Object System.Drawing.Size(150,20)
    $checkUncheckCheckBox.Text = 'Check/Uncheck all'
    $checkUncheckCheckBox.add_CheckedChanged($check_All)

    $form.Controls.Add($checkUncheckCheckBox)

    $selectionBox.FormattingEnabled = $True
    $selectionBox.DataBindings.DefaultDataSourceUpdateMode = 0
    $selectionBox.Name = "selectionBox"
    $selectionBox.Location = New-Object System.Drawing.Point(13,43)
    $selectionBox.Size = New-Object System.Drawing.Size(374,424)
    $selectionBox.TabIndex = 3
    $selectionBox.add_SelectedIndexChanged($selectionBox_SelectedIndexChanged)
    $selectionBox.add_Click($selectionBox_MouseDown)

    $form.Controls.Add($selectionBox)
    # Save intial state
    $initialFormWindowState = $form.WindowState
    # Load apps
    $form.add_Load($load_Apps)
    # Focus selectionBox when form opens
    $form.Add_Shown({$form.Activate(); $selectionBox.Focus()})
    # Show the Form
    return $form.ShowDialog()

    $selectedAppsToUninstall = Get-Content -Path '$ENV:temp//CustomAppsList.txt'
    
    foreach($checkedAppName in $selectedAppsToUninstall) {
        try {
            Get-AppxPackage | Out-File -Path '.\Log.txt'
        }
        catch {
            Write-Host "Error while uninstalling " + $checkedAppName
        }
    }

    Pause
    DisableServicesConsent
}
function DisableServicesConsent {
    Clear-Host
    Write-Host "◦ Step 2: Disable or set services to manual." -ForegroundColor Green
    $yesnosvc = Read-Host "This section of the script will disable or change the startup type of several services to manual. It will disable Fax, Printing, Etc. that are not used by most users. To enable Printing, go to services.msc and enable them. Do you want to continue? (Y/N)"
    switch ($yesnosvc) {
        "y" { DisableServices }
        "n" {
            Clear-Host
            MainMenu
            }
    }
}

function DisableServices {
    
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
        Clear-Host
        Write-Host "Success!" -ForegroundColor Green
        Pause
        MainMenu
}

function MainMenu {
    Clear-Host
    Write-Host "┌───────────────────────────────────────────────────────────────┐"
    Write-Host "│   Select an option:                                           │"
    Write-Host "├───────────────────────────────────────────────────────────────┤"
    Write-Host "│   1. Remove useless Bloat and disable services                │"
    Write-Host "│   2. Run O&O ShutUp10++ (Recommended)                         │"
    Write-Host "│   4. Custom WIM Builder                                       │"
    Write-Host "│   5. Exit Script                                              │"
    Write-Host "└───────────────────────────────────────────────────────────────┘"
}

while ($true) {
    MainMenu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" { Debloat }
        "2" { OOSU }
        "3" { WIMModifier }
        "4" { exit }
        default { Write-Host "Invalid option. Please enter a number between 1 and 5." }
    }
}
