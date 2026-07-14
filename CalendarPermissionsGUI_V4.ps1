Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Module check (runs before the form opens) ─────────────────────────────────
$moduleInstalled = $null -ne (Get-Module -ListAvailable -Name ExchangeOnlineManagement)
if (-not $moduleInstalled) {
    $result = [System.Windows.Forms.MessageBox]::Show(
        "The ExchangeOnlineManagement module is not installed.`n`nWould you like to install it now? (Requires internet access and may prompt for admin rights)",
        "Module Not Found",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($result -eq "Yes") {
        try {
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
            [System.Windows.Forms.MessageBox]::Show("Module installed successfully. You can now connect.", "Installed", "OK", "Information")
            $moduleInstalled = $true
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Installation failed:`n$_`n`nPlease run: Install-Module ExchangeOnlineManagement -Scope CurrentUser", "Error", "OK", "Error")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("The module is required to use this tool. Exiting.", "Exiting", "OK", "Error")
        exit
    }
}

# ── Form ──────────────────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "Calendar Permissions Manager"
$form.Size = New-Object System.Drawing.Size(580, 620)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::WhiteSmoke
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# ── Section: Exchange Online ──────────────────────────────────────────────────
$lblExchange = New-Object System.Windows.Forms.Label
$lblExchange.Text = "EXCHANGE ONLINE"
$lblExchange.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblExchange.ForeColor = [System.Drawing.Color]::Gray
$lblExchange.Location = New-Object System.Drawing.Point(16, 16)
$lblExchange.Size = New-Object System.Drawing.Size(200, 16)
$form.Controls.Add($lblExchange)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(16, 36)
$txtUser.Size = New-Object System.Drawing.Size(300, 24)
$txtUser.PlaceholderText = "admin@yourdomain.com (optional)"
$form.Controls.Add($txtUser)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Text = "Connect"
$btnConnect.Location = New-Object System.Drawing.Point(326, 35)
$btnConnect.Size = New-Object System.Drawing.Size(80, 26)
$btnConnect.BackColor = [System.Drawing.Color]::FromArgb(24, 95, 165)
$btnConnect.ForeColor = [System.Drawing.Color]::White
$btnConnect.FlatStyle = "Flat"
$btnConnect.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnConnect)

$btnDisconnect = New-Object System.Windows.Forms.Button
$btnDisconnect.Text = "Disconnect"
$btnDisconnect.Location = New-Object System.Drawing.Point(414, 35)
$btnDisconnect.Size = New-Object System.Drawing.Size(90, 26)
$btnDisconnect.BackColor = [System.Drawing.Color]::FromArgb(160, 50, 50)
$btnDisconnect.ForeColor = [System.Drawing.Color]::White
$btnDisconnect.FlatStyle = "Flat"
$btnDisconnect.FlatAppearance.BorderSize = 0
$btnDisconnect.Enabled = $false
$form.Controls.Add($btnDisconnect)

$lblModStatus = New-Object System.Windows.Forms.Label
$lblModStatus.Text = if ($moduleInstalled) { "Module: installed ✔" } else { "Module: missing ✘" }
$lblModStatus.ForeColor = if ($moduleInstalled) { [System.Drawing.Color]::FromArgb(59, 109, 17) } else { [System.Drawing.Color]::Red }
$lblModStatus.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblModStatus.Location = New-Object System.Drawing.Point(416, 16)
$lblModStatus.Size = New-Object System.Drawing.Size(148, 16)
$form.Controls.Add($lblModStatus)

$lblConnStatus = New-Object System.Windows.Forms.Label
$lblConnStatus.Text = "Not connected"
$lblConnStatus.ForeColor = [System.Drawing.Color]::Gray
$lblConnStatus.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblConnStatus.Location = New-Object System.Drawing.Point(416, 39)
$lblConnStatus.Size = New-Object System.Drawing.Size(148, 18)
$form.Controls.Add($lblConnStatus)

# ── Divider ───────────────────────────────────────────────────────────────────
$sep1 = New-Object System.Windows.Forms.Label
$sep1.BorderStyle = "Fixed3D"
$sep1.Location = New-Object System.Drawing.Point(16, 72)
$sep1.Size = New-Object System.Drawing.Size(538, 2)
$form.Controls.Add($sep1)

# ── Section: Action + Access Rights ──────────────────────────────────────────
$lblAction = New-Object System.Windows.Forms.Label
$lblAction.Text = "ACTION"
$lblAction.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblAction.ForeColor = [System.Drawing.Color]::Gray
$lblAction.Location = New-Object System.Drawing.Point(16, 84)
$lblAction.Size = New-Object System.Drawing.Size(140, 16)
$form.Controls.Add($lblAction)

$cboAction = New-Object System.Windows.Forms.ComboBox
$cboAction.Location = New-Object System.Drawing.Point(16, 104)
$cboAction.Size = New-Object System.Drawing.Size(140, 24)
$cboAction.DropDownStyle = "DropDownList"
@("Add Access","Edit Access","Remove Access") | ForEach-Object { $cboAction.Items.Add($_) }
$cboAction.SelectedIndex = 0
$form.Controls.Add($cboAction)

$lblRights = New-Object System.Windows.Forms.Label
$lblRights.Text = "ACCESS RIGHTS"
$lblRights.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblRights.ForeColor = [System.Drawing.Color]::Gray
$lblRights.Location = New-Object System.Drawing.Point(170, 84)
$lblRights.Size = New-Object System.Drawing.Size(160, 16)
$form.Controls.Add($lblRights)

$cboRights = New-Object System.Windows.Forms.ComboBox
$cboRights.Location = New-Object System.Drawing.Point(170, 104)
$cboRights.Size = New-Object System.Drawing.Size(200, 24)
$cboRights.DropDownStyle = "DropDownList"
@("Editor","Reviewer","Author","PublishingEditor","PublishingAuthor","Owner","NonEditingAuthor","AvailabilityOnly","LimitedDetails") | ForEach-Object { $cboRights.Items.Add($_) }
$cboRights.SelectedIndex = 0
$form.Controls.Add($cboRights)

$chkDelegate = New-Object System.Windows.Forms.CheckBox
$chkDelegate.Text = "Set as Delegate (-SharingPermissionFlags Delegate)"
$chkDelegate.Location = New-Object System.Drawing.Point(385, 104)
$chkDelegate.Size = New-Object System.Drawing.Size(148, 40)
$chkDelegate.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$chkDelegate.Checked = $false
$form.Controls.Add($chkDelegate)

# Hide Access Rights and Delegate checkbox when Remove is selected (not applicable)
$cboAction.Add_SelectedIndexChanged({
    $isRemove = $cboAction.SelectedItem -eq "Remove Access"
    $lblRights.Visible = -not $isRemove
    $cboRights.Visible = -not $isRemove
    $chkDelegate.Visible = -not $isRemove
})

# ── Divider ───────────────────────────────────────────────────────────────────
$sep2 = New-Object System.Windows.Forms.Label
$sep2.BorderStyle = "Fixed3D"
$sep2.Location = New-Object System.Drawing.Point(16, 138)
$sep2.Size = New-Object System.Drawing.Size(538, 2)
$form.Controls.Add($sep2)

# ── TabControl: CSV vs Manual ─────────────────────────────────────────────────
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(16, 148)
$tabs.Size = New-Object System.Drawing.Size(538, 170)
$tabs.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($tabs)

# Tab 1: CSV
$tabCsv = New-Object System.Windows.Forms.TabPage
$tabCsv.Text = "  CSV File  "
$tabs.Controls.Add($tabCsv)

$lblCsvHint = New-Object System.Windows.Forms.Label
$lblCsvHint.Text = "Required columns: UserEmail, DelegateEmail"
$lblCsvHint.ForeColor = [System.Drawing.Color]::Gray
$lblCsvHint.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblCsvHint.Location = New-Object System.Drawing.Point(8, 12)
$lblCsvHint.Size = New-Object System.Drawing.Size(350, 16)
$tabCsv.Controls.Add($lblCsvHint)

$txtCsv = New-Object System.Windows.Forms.TextBox
$txtCsv.Text = "C:\Temp\mailboxes.csv"
$txtCsv.Location = New-Object System.Drawing.Point(8, 34)
$txtCsv.Size = New-Object System.Drawing.Size(400, 24)
$tabCsv.Controls.Add($txtCsv)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse..."
$btnBrowse.Location = New-Object System.Drawing.Point(416, 33)
$btnBrowse.Size = New-Object System.Drawing.Size(80, 26)
$btnBrowse.FlatStyle = "Flat"
$tabCsv.Controls.Add($btnBrowse)

# Tab 2: Manual Entry
$tabManual = New-Object System.Windows.Forms.TabPage
$tabManual.Text = "  Manual Entry  "
$tabs.Controls.Add($tabManual)

$lblManualHint = New-Object System.Windows.Forms.Label
$lblManualHint.Text = "Enter mailbox and delegate email addresses directly:"
$lblManualHint.ForeColor = [System.Drawing.Color]::Gray
$lblManualHint.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblManualHint.Location = New-Object System.Drawing.Point(8, 10)
$lblManualHint.Size = New-Object System.Drawing.Size(400, 16)
$tabManual.Controls.Add($lblManualHint)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(8, 30)
$grid.Size = New-Object System.Drawing.Size(506, 90)
$grid.ColumnHeadersHeightSizeMode = "DisableResizing"
$grid.ColumnHeadersHeight = 24
$grid.RowHeadersVisible = $false
$grid.AllowUserToAddRows = $true
$grid.AllowUserToDeleteRows = $true
$grid.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$grid.BackgroundColor = [System.Drawing.Color]::White
$grid.GridColor = [System.Drawing.Color]::LightGray
$grid.BorderStyle = "FixedSingle"
$col1 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$col1.HeaderText = "UserEmail"
$col1.Name = "UserEmail"
$col1.Width = 240
$col2 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$col2.HeaderText = "DelegateEmail"
$col2.Name = "DelegateEmail"
$col2.Width = 240
$grid.Columns.Add($col1) | Out-Null
$grid.Columns.Add($col2) | Out-Null
$tabManual.Controls.Add($grid)

$btnAddRow = New-Object System.Windows.Forms.Button
$btnAddRow.Text = "+ Add Row"
$btnAddRow.Location = New-Object System.Drawing.Point(8, 128)
$btnAddRow.Size = New-Object System.Drawing.Size(90, 24)
$btnAddRow.FlatStyle = "Flat"
$tabManual.Controls.Add($btnAddRow)

$btnRemoveRow = New-Object System.Windows.Forms.Button
$btnRemoveRow.Text = "Remove Selected"
$btnRemoveRow.Location = New-Object System.Drawing.Point(106, 128)
$btnRemoveRow.Size = New-Object System.Drawing.Size(120, 24)
$btnRemoveRow.FlatStyle = "Flat"
$tabManual.Controls.Add($btnRemoveRow)

# ── Divider ───────────────────────────────────────────────────────────────────
$sep3 = New-Object System.Windows.Forms.Label
$sep3.BorderStyle = "Fixed3D"
$sep3.Location = New-Object System.Drawing.Point(16, 328)
$sep3.Size = New-Object System.Drawing.Size(538, 2)
$form.Controls.Add($sep3)

# ── Output Log ────────────────────────────────────────────────────────────────
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "OUTPUT"
$lblOutput.Font = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)
$lblOutput.ForeColor = [System.Drawing.Color]::Gray
$lblOutput.Location = New-Object System.Drawing.Point(16, 340)
$lblOutput.Size = New-Object System.Drawing.Size(200, 16)
$form.Controls.Add($lblOutput)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location = New-Object System.Drawing.Point(16, 360)
$txtLog.Size = New-Object System.Drawing.Size(538, 170)
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$txtLog.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = "Vertical"
$form.Controls.Add($txtLog)

# ── Buttons: Clear + Run ──────────────────────────────────────────────────────
$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear Log"
$btnClear.Location = New-Object System.Drawing.Point(290, 542)
$btnClear.Size = New-Object System.Drawing.Size(80, 28)
$btnClear.FlatStyle = "Flat"
$form.Controls.Add($btnClear)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "▶  Run"
$btnRun.Location = New-Object System.Drawing.Point(380, 542)
$btnRun.Size = New-Object System.Drawing.Size(76, 28)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(59, 109, 17)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRun)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(466, 542)
$btnExit.Size = New-Object System.Drawing.Size(84, 28)
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$btnExit.ForeColor = [System.Drawing.Color]::White
$btnExit.FlatStyle = "Flat"
$btnExit.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnExit)

# ── Status Bar ────────────────────────────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Status: Idle"
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# ── Helper: Append coloured text to log ──────────────────────────────────────
function Write-Log {
    param([string]$Text, [System.Drawing.Color]$Color = [System.Drawing.Color]::FromArgb(200,200,200))
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.SelectionLength = 0
    $txtLog.SelectionColor = $Color
    $txtLog.AppendText("$Text`n")
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ── Helper: Process a list of mailbox objects ─────────────────────────────────
function Invoke-Permissions {
    param([array]$Mailboxes, [string]$Action, [string]$AccessRights, [bool]$SetDelegate = $false)
    $success = 0; $failed = 0
    $total = $Mailboxes.Count
    Write-Log "Action: $Action — $total entries to process." ([System.Drawing.Color]::Gray)
    Write-Log ("─" * 52) ([System.Drawing.Color]::FromArgb(80,80,80))

    foreach ($row in $Mailboxes) {
        $email    = $row.UserEmail.Trim()
        $delegate = $row.DelegateEmail.Trim()
        if (-not $email -or -not $delegate) {
            Write-Log "  Skipping empty row." ([System.Drawing.Color]::FromArgb(150,150,80))
            continue
        }
        Write-Log "Processing: $email  →  Delegate: $delegate" ([System.Drawing.Color]::FromArgb(78, 201, 176))
        try {
            switch ($Action) {
                "Add Access" {
                    if ($SetDelegate) {
                        Add-MailboxFolderPermission -Identity "$($email):\Calendar" -User $delegate -AccessRights $AccessRights -SharingPermissionFlags Delegate -ErrorAction Stop
                    } else {
                        Add-MailboxFolderPermission -Identity "$($email):\Calendar" -User $delegate -AccessRights $AccessRights -ErrorAction Stop
                    }
                    $delegateNote = if ($SetDelegate) { " + Delegate flag" } else { "" }
                    Write-Log "  ✔ Access added ($AccessRights$delegateNote)." ([System.Drawing.Color]::FromArgb(106, 153, 85))
                }
                "Edit Access" {
                    if ($SetDelegate) {
                        Set-MailboxFolderPermission -Identity "$($email):\Calendar" -User $delegate -AccessRights $AccessRights -SharingPermissionFlags Delegate -ErrorAction Stop
                    } else {
                        Set-MailboxFolderPermission -Identity "$($email):\Calendar" -User $delegate -AccessRights $AccessRights -ErrorAction Stop
                    }
                    $delegateNote = if ($SetDelegate) { " + Delegate flag" } else { "" }
                    Write-Log "  ✔ Access updated to $AccessRights$delegateNote." ([System.Drawing.Color]::FromArgb(106, 153, 85))
                }
                "Remove Access" {
                    Remove-MailboxFolderPermission -Identity "$($email):\Calendar" -User $delegate -Confirm:$false -ErrorAction Stop
                    Write-Log "  ✔ Access removed." ([System.Drawing.Color]::FromArgb(106, 153, 85))
                }
            }
            $success++
        } catch {
            Write-Log "  ✘ Failed: $_" ([System.Drawing.Color]::FromArgb(220, 80, 80))
            $failed++
        }
    }

    Write-Log ("─" * 52) ([System.Drawing.Color]::FromArgb(80,80,80))
    Write-Log "Done. $success succeeded, $failed failed." ([System.Drawing.Color]::FromArgb(200,200,200))
    return @{ Success = $success; Failed = $failed }
}

# ── Browse CSV ────────────────────────────────────────────────────────────────
$btnBrowse.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $ofd.InitialDirectory = "C:\Temp"
    if ($ofd.ShowDialog() -eq "OK") { $txtCsv.Text = $ofd.FileName }
})

# ── Add / Remove grid rows ────────────────────────────────────────────────────
$btnAddRow.Add_Click({ $grid.Rows.Add() | Out-Null })
$btnRemoveRow.Add_Click({
    foreach ($row in @($grid.SelectedRows)) { $grid.Rows.Remove($row) }
})

# ── Connect ───────────────────────────────────────────────────────────────────
$btnConnect.Add_Click({
    $lblConnStatus.Text = "Connecting..."
    $lblConnStatus.ForeColor = [System.Drawing.Color]::DarkOrange
    $form.Refresh()
    try {
        Write-Log "Checking for ExchangeOnlineManagement updates..." ([System.Drawing.Color]::Gray)
        Update-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        if ($txtUser.Text.Trim() -ne "") {
            Connect-ExchangeOnline -UserPrincipalName $txtUser.Text.Trim() -ErrorAction Stop
        } else {
            Connect-ExchangeOnline -ErrorAction Stop
        }
        $lblConnStatus.Text = "Connected ✔"
        $lblConnStatus.ForeColor = [System.Drawing.Color]::FromArgb(59, 109, 17)
        Write-Log "Connected to Exchange Online." ([System.Drawing.Color]::FromArgb(106, 153, 85))
        $btnDisconnect.Enabled = $true
        $btnConnect.Enabled = $false
    } catch {
        $lblConnStatus.Text = "Failed ✘"
        $lblConnStatus.ForeColor = [System.Drawing.Color]::Red
        Write-Log "Connection failed: $_" ([System.Drawing.Color]::FromArgb(220, 80, 80))
        $btnDisconnect.Enabled = $false
    }
})

# ── Disconnect ────────────────────────────────────────────────────────────────
$btnDisconnect.Add_Click({
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop
        $lblConnStatus.Text = "Disconnected"
        $lblConnStatus.ForeColor = [System.Drawing.Color]::Gray
        Write-Log "Disconnected from Exchange Online." ([System.Drawing.Color]::Gray)
    } catch {
        Write-Log "Disconnect error: $_" ([System.Drawing.Color]::FromArgb(220, 80, 80))
    } finally {
        $btnDisconnect.Enabled = $false
        $btnConnect.Enabled = $true
    }
})

# ── Clear Log ─────────────────────────────────────────────────────────────────
$btnClear.Add_Click({ $txtLog.Clear() })

# ── Run ───────────────────────────────────────────────────────────────────────
$btnRun.Add_Click({
    $action      = $cboAction.SelectedItem
    $accessRights = $cboRights.SelectedItem
    $setDelegate  = $chkDelegate.Checked

    # Confirm destructive actions
    if ($action -eq "Remove Access") {
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "You are about to REMOVE calendar access for all listed delegates.`n`nAre you sure?",
            "Confirm Remove",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($confirm -ne "Yes") { return }
    }

    $btnRun.Enabled = $false
    $statusLabel.Text = "Status: Running..."
    $form.Refresh()

    try {
        if ($tabs.SelectedTab -eq $tabCsv) {
            $csvPath = $txtCsv.Text.Trim()
            if (-not (Test-Path $csvPath)) {
                [System.Windows.Forms.MessageBox]::Show("CSV file not found:`n$csvPath", "File Not Found", "OK", "Warning")
                return
            }
            $mailboxes = Import-Csv -Path $csvPath
            $result = Invoke-Permissions -Mailboxes $mailboxes -Action $action -AccessRights $accessRights -SetDelegate $setDelegate
        } else {
            $mailboxes = @()
            foreach ($row in $grid.Rows) {
                if ($row.IsNewRow) { continue }
                $mailboxes += [PSCustomObject]@{
                    UserEmail     = "$($row.Cells['UserEmail'].Value)"
                    DelegateEmail = "$($row.Cells['DelegateEmail'].Value)"
                }
            }
            if ($mailboxes.Count -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("No entries found in the manual grid.", "Nothing to process", "OK", "Warning")
                return
            }
            $result = Invoke-Permissions -Mailboxes $mailboxes -Action $action -AccessRights $accessRights -SetDelegate $setDelegate
        }
        $statusLabel.Text = "Status: Done — $($result.Success) OK, $($result.Failed) failed"
    } catch {
        Write-Log "Unexpected error: $_" ([System.Drawing.Color]::FromArgb(220, 80, 80))
        $statusLabel.Text = "Status: Error"
    } finally {
        $btnRun.Enabled = $true
    }
})

# ── Launch ────────────────────────────────────────────────────────────────────
Write-Log "Ready. Connect to Exchange Online, then choose CSV or Manual Entry." ([System.Drawing.Color]::Gray)
[System.Windows.Forms.Application]::EnableVisualStyles()
$form.ShowDialog() | Out-Null

# ── Exit button ───────────────────────────────────────────────────────────────
$script:disconnectOnExit = {
    if ($btnDisconnect.Enabled) {
        try {
            Write-Log "Disconnecting from Exchange Online..." ([System.Drawing.Color]::Gray)
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop
            Write-Log "Disconnected." ([System.Drawing.Color]::Gray)
        } catch {
            # Silently ignore disconnect errors on exit
        }
    }
}

$btnExit.Add_Click({
    & $script:disconnectOnExit
    $form.Close()
})

# Also disconnect if the user closes via the X button
$form.Add_FormClosing({
    & $script:disconnectOnExit
})
