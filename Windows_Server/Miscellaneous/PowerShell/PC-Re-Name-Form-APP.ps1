CLS
set-executionpolicy -scope CurrentUser -executionPolicy Bypass -force
set-executionpolicy -scope LocalMachine -executionPolicy Bypass -force
set-executionpolicy -scope Process -executionPolicy Bypass -force

#######################################################################################################################
    #
Function MakeNewForm {
	$objForm.Close()
	$objForm.Dispose()
	Load-objForm
} ### END Function MakeNewForm
    #
#######################################################################################################################
    #
function Load-objForm {
	#
	# Start Import the Assemblies
	#
	[void][reflection.assembly]::LoadWithPartialName('System.Windows.Forms')
	[void][reflection.assembly]::LoadWithPartialName('System.Data')
	[void][reflection.assembly]::LoadWithPartialName('System.Drawing')
	#
	# Start objForm Objects
	#
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$objForm = New-Object 'System.Windows.Forms.Form'
	$TBComputerName = New-Object 'System.Windows.Forms.TextBox'
    $TBComputerNameConfirm = New-Object 'System.Windows.Forms.TextBox'
	$objLabel = New-Object 'System.Windows.Forms.Label'
    $LocationIDLabel = New-Object 'System.Windows.Forms.Label'
    $ConfirmIDLabel = New-Object 'System.Windows.Forms.Label'
	$ButtonOK = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
    $comboBox1 = New-Object 'System.Windows.Forms.ComboBox'
    $PCCBLabel = New-Object 'System.Windows.Forms.Label'
	#
    # This will prevent the .Net maximized form issue
    $objForm_StateCorrection_Load = {
		$objForm.WindowState = $InitialFormWindowState
	}
	#
    # This will Remove all event handlers from the controls
    $objForm_Cleanup_FormClosed = {
		try {
			$objForm.remove_Load($objForm_Load)
			$objForm.remove_Load($objForm_StateCorrection_Load)
			$objForm.remove_FormClosed($objForm_Cleanup_FormClosed)
		}
		catch [Exception]
		    { }
	}
	#
#######################################################################################################################
    #
function Load-ErrorForm1 {
    #
    #
	# Start Import the Assemblies
	#
	[void][reflection.assembly]::LoadWithPartialName('System.Windows.Forms')
	[void][reflection.assembly]::LoadWithPartialName('System.Data')
	[void][reflection.assembly]::LoadWithPartialName('System.Drawing')
	#
	# Start objForm Objects
	#
	[System.Windows.Forms.Application]::EnableVisualStyles()
    $ErrorForm1 = New-Object 'System.Windows.Forms.Form'
    $ErrorLabel1 = New-Object 'System.Windows.Forms.Label'
    $ErrorButtonOK1 = New-Object 'System.Windows.Forms.Button'
    $InitialFormWindowState1 = New-Object 'System.Windows.Forms.FormWindowState'
    #
    # This will prevent the .Net maximized form issue
	#
    $ErrorForm1_StateCorrection_Load = {
		$ErrorForm1.WindowState = $InitialFormWindowState1
	}
	#
    # This will Remove all event handlers from the controls
    $ErrorForm1_Cleanup_FormClosed = {
		try {
			$ErrorForm1.remove_Load($ErrorForm1_Load)
			$ErrorForm1.remove_Load($ErrorForm1_StateCorrection_Load)
			$ErrorForm1.remove_FormClosed($ErrorForm1_Cleanup_FormClosed)
		}
		catch [Exception]
		    { }
	}
	#
    # ErrorForm1
    #
    $ErrorForm1.Controls.Add($ErrorLabel1)
    $ErrorForm1.Controls.Add($ErrorButtonOK1)
    $ErrorForm1.AcceptButton = $ErrorButtonOK1
    $ErrorForm1.SuspendLayout()
	$ErrorForm1.AutoScaleDimensions = '96, 96'
	$ErrorForm1.AutoScaleMode = 'Dpi'
    $ErrorForm1.Topmost = $True
    $ErrorForm1.Add_Shown({$ErrorForm1.Activate()})
    $ErrorForm1.BackgroundImageLayout = 'Center'
	$ErrorForm1.ClientSize = '550, 150'
	$ErrorForm1.ControlBox = $False
	$ErrorForm1.Font = 'Microsoft Sans Serif, 12pt, style=Bold'
	$ErrorForm1.FormBorderStyle = 'FixedDialog'
	$ErrorForm1.Margin = '4, 5, 4, 5'
	$ErrorForm1.MaximizeBox = $False
	$ErrorForm1.MinimizeBox = $False
	$ErrorForm1.Name = 'objForm'
	$ErrorForm1.ShowIcon = $False
	$ErrorForm1.SizeGripStyle = 'Hide'
	$ErrorForm1.StartPosition = 'CenterScreen'
	$ErrorForm1.Text = 'X IT - Retail Application Support'
    $ErrorForm1.BackColor = 'Red'
    #
    # ErrorLabel1
    #
    $ErrorLabel1.AutoSize = $True
	$ErrorLabel1.BackColor = 'Transparent'
	$ErrorLabel1.Font = 'Microsoft Sans Serif, 25pt, style=Bold'
	$ErrorLabel1.Location = '-5, 9'
	$ErrorLabel1.Margin = '4, 0, 4, 0'
	$ErrorLabel1.Name = 'ErrorLabel'
	$ErrorLabel1.Size = '550, 50'
	$ErrorLabel1.Text = ' The Location ID entered must be 
 exactly 8 characters in length. '
    #
    # The below Will enable the "form varriable" within the () to load also. EXAMPLE: $objForm_Load = {This code will now execute}
    $ErrorForm1.add_Load($ErrorForm1_Load) 
	#
    # ErrorButtonOK1
    # 
    $ErrorButtonOK1.Anchor = 'Bottom, Right'
	$ErrorButtonOK1.DialogResult = 'OK'
	$ErrorButtonOK1.Location = '375, 100'
	$ErrorButtonOK1.Margin = '4, 5, 4, 5'
	$ErrorButtonOK1.Name = 'ButtonOK'
	$ErrorButtonOK1.Size = '125, 40'
	$ErrorButtonOK1.TabIndex = 1
	$ErrorButtonOK1.Text = 'OK'
	$ErrorButtonOK1.UseVisualStyleBackColor = $True
    #
    # The below will allow the Fucntion "Set-ARComputerName" to execute and close the Application.
    $ErrorButtonOK1.Add_Click({if ($_) {$ErrorForm1.Close()}})
    #
	# objForm resumes the layout of the form
    $ErrorForm1.ResumeLayout()
	#
	# Save the initial state of the form
	$InitialFormWindowState1 = $ErrorForm1.WindowState
	#
    # Load event to correct the initial state of the form
    $ErrorForm1.add_Load($ErrorForm1_StateCorrection_Load)
    #	
    # Clean up the control events
    $ErrorForm1.add_FormClosed($ErrorForm1_Cleanup_FormClosed)
	#
    # Show the Form
    return $ErrorForm1.ShowDialog()
    #
} ### END function Load-ErrorForm1
    #
#######################################################################################################################
    #
function Load-ErrorForm2 {
    #
	# Start Import the Assemblies
	#
	[void][reflection.assembly]::LoadWithPartialName('System.Windows.Forms')
	[void][reflection.assembly]::LoadWithPartialName('System.Data')
	[void][reflection.assembly]::LoadWithPartialName('System.Drawing')
	#
	# Start objForm Objects
	#
	[System.Windows.Forms.Application]::EnableVisualStyles()
    $ErrorForm2 = New-Object 'System.Windows.Forms.Form'
    $ErrorLabel2 = New-Object 'System.Windows.Forms.Label'
    $ErrorButtonOK2 = New-Object 'System.Windows.Forms.Button'
    $InitialFormWindowState2 = New-Object 'System.Windows.Forms.FormWindowState'
	#
    # This will prevent the .Net maximized form issue
    $ErrorForm2_StateCorrection_Load = {
		$ErrorForm2.WindowState = $InitialFormWindowState2
	}
	#
    # This will Remove all event handlers from the controls
    $ErrorForm2_Cleanup_FormClosed = {
		try {
			$ErrorForm2.remove_Load($ErrorForm2_Load)
			$ErrorForm2.remove_Load($ErrorForm2_StateCorrection_Load)
			$ErrorForm2.remove_FormClosed($ErrorForm2_Cleanup_FormClosed)
		}
		catch [Exception]
		    { }
	}
	#
    # $ErrorForm2 Code
    #
    $ErrorForm2.Controls.Add($ErrorLabel2)
    $ErrorForm2.Controls.Add($ErrorButtonOK2)
    $ErrorForm2.AcceptButton = $ErrorButtonOK2
    $ErrorForm2.SuspendLayout()
	$ErrorForm2.AutoScaleDimensions = '96, 96'
	$ErrorForm2.AutoScaleMode = 'Dpi'
    $ErrorForm2.Topmost = $True
    $ErrorForm2.Add_Shown({$ErrorForm2.Activate()})
    $ErrorForm2.BackgroundImageLayout = 'Center'
	$ErrorForm2.ClientSize = '550, 150'
	$ErrorForm2.ControlBox = $False
	$ErrorForm2.Font = 'Microsoft Sans Serif, 12pt, style=Bold'
	$ErrorForm2.FormBorderStyle = 'FixedDialog'
	$ErrorForm2.Margin = '4, 5, 4, 5'
	$ErrorForm2.MaximizeBox = $False
	$ErrorForm2.MinimizeBox = $False
	$ErrorForm2.Name = 'objForm'
	$ErrorForm2.ShowIcon = $False
	$ErrorForm2.SizeGripStyle = 'Hide'
	$ErrorForm2.StartPosition = 'CenterScreen'
	$ErrorForm2.Text = 'X IT - Retail Application Support'
    $ErrorForm2.BackColor = 'Red'
    #
    # $ErrorLabel2 Code
    #
    $ErrorLabel2.AutoSize = $True
	$ErrorLabel2.BackColor = 'Transparent'
	$ErrorLabel2.Font = 'Microsoft Sans Serif, 25pt, style=Bold'
	$ErrorLabel2.Location = '-5, 9'
	$ErrorLabel2.Margin = '4, 0, 4, 0'
	$ErrorLabel2.Name = 'ErrorLabel'
	$ErrorLabel2.Size = '550, 50'
	$ErrorLabel2.Text = ' The Confirmation Field does not  
 match the Location ID Field. '
	#
    # The below Will enable the "form varriable" within the () to load also. EXAMPLE: $objForm_Load = {This code will now execute}
    #
    $ErrorForm2.add_Load($ErrorForm2_Load) 
	#
    $ErrorButtonOK2.Anchor = 'Bottom, Right'
	$ErrorButtonOK2.DialogResult = 'OK'
	$ErrorButtonOK2.Location = '375, 100'
	$ErrorButtonOK2.Margin = '4, 5, 4, 5'
	$ErrorButtonOK2.Name = 'ButtonOK'
	$ErrorButtonOK2.Size = '125, 40'
	$ErrorButtonOK2.TabIndex = 1
	$ErrorButtonOK2.Text = 'OK'
	$ErrorButtonOK2.UseVisualStyleBackColor = $True
    #
    # The below will allow the Fucntion "Set-ARComputerName" to execute and close the Application.
    #
    $ErrorButtonOK2.Add_Click({if ($_) {$ErrorForm2.Close()}})
    #
	# objForm resumes the layout of the form 
    $ErrorForm2.ResumeLayout()
	#
	# Save the initial state of the form
	$InitialFormWindowState2 = $ErrorForm2.WindowState
	#
    # Load event to correct the initial state of the form
    $ErrorForm2.add_Load($ErrorForm2_StateCorrection_Load)
    #	
    # Clean up the control events
    $ErrorForm2.add_FormClosed($ErrorForm2_Cleanup_FormClosed)
	#
    # Show the Form
    return $ErrorForm2.ShowDialog()
    #
} ### End function Load-ErrorForm2
    #
#######################################################################################################################
    #
function Load-ErrorForm3 {
    #
	# Start Import the Assemblies
	#
	[void][reflection.assembly]::LoadWithPartialName('System.Windows.Forms')
	[void][reflection.assembly]::LoadWithPartialName('System.Data')
	[void][reflection.assembly]::LoadWithPartialName('System.Drawing')
	#
	# Start objForm Objects
	#
	[System.Windows.Forms.Application]::EnableVisualStyles()
    $ErrorForm3 = New-Object 'System.Windows.Forms.Form'
    $ErrorLabel3 = New-Object 'System.Windows.Forms.Label'
    $ErrorButtonOK3 = New-Object 'System.Windows.Forms.Button'
    $InitialFormWindowState3 = New-Object 'System.Windows.Forms.FormWindowState'
    #
    # This will prevent the .Net maximized form issue
    $ErrorForm3_StateCorrection_Load = {
		$ErrorForm3.WindowState = $InitialFormWindowState3
	}
	#
    # This will Remove all event handlers from the controls
    $ErrorForm3_Cleanup_FormClosed = {
		try {
			$ErrorForm3.remove_Load($ErrorForm3_Load)
			$ErrorForm3.remove_Load($ErrorForm3_StateCorrection_Load)
			$ErrorForm3.remove_FormClosed($ErrorForm3_Cleanup_FormClosed)
		} 
        catch [Exception]
		    { }
	}
	#
    # $ErrorForm3 Code
    #
    $ErrorForm3.Controls.Add($ErrorLabel3)
    $ErrorForm3.Controls.Add($ErrorButtonOK3)
    $ErrorForm3.AcceptButton = $ErrorButtonOK3
    $ErrorForm3.SuspendLayout()
	$ErrorForm3.AutoScaleDimensions = '96, 96'
	$ErrorForm3.AutoScaleMode = 'Dpi'
    $ErrorForm3.Topmost = $True
    $ErrorForm3.Add_Shown({$ErrorForm3.Activate()})
    $ErrorForm3.BackgroundImageLayout = 'Center'
	$ErrorForm3.ClientSize = '550, 150'
	$ErrorForm3.ControlBox = $False
	$ErrorForm3.Font = 'Microsoft Sans Serif, 12pt, style=Bold'
	$ErrorForm3.FormBorderStyle = 'FixedDialog'
	$ErrorForm3.Margin = '4, 5, 4, 5'
	$ErrorForm3.MaximizeBox = $False
	$ErrorForm3.MinimizeBox = $False
	$ErrorForm3.Name = 'objForm'
	$ErrorForm3.ShowIcon = $False
	$ErrorForm3.SizeGripStyle = 'Hide'
	$ErrorForm3.StartPosition = 'CenterScreen'
	$ErrorForm3.Text = 'X IT - Retail Application Support'
    $ErrorForm3.BackColor = 'Red'
    #
    # $ErrorLabel3 Code
    #
    $ErrorLabel3.AutoSize = $True
	$ErrorLabel3.BackColor = 'Transparent'
	$ErrorLabel3.Font = 'Microsoft Sans Serif, 25pt, style=Bold'
	$ErrorLabel3.Location = '-5, 9'
	$ErrorLabel3.Margin = '4, 0, 4, 0'
	$ErrorLabel3.Name = 'ErrorLabel'
	$ErrorLabel3.Size = '550, 50'
	$ErrorLabel3.Text = ' A PC Number was Not selected in
 the drop down list. '
	#
    # The below Will enable the "form varriable" within the () to load also. EXAMPLE: $objForm_Load = {This code will now execute}
    $ErrorForm3.add_Load($ErrorForm3_Load) 
	#
    $ButtonOK.Anchor = 'Bottom, Right'
	$ErrorButtonOK3.DialogResult = 'OK'
	$ErrorButtonOK3.Location = '375, 100'
	$ErrorButtonOK3.Margin = '4, 5, 4, 5'
	$ErrorButtonOK3.Name = 'ButtonOK'
	$ErrorButtonOK3.Size = '125, 40'
	$ErrorButtonOK3.TabIndex = 1
	$ErrorButtonOK3.Text = 'OK'
	$ErrorButtonOK3.UseVisualStyleBackColor = $True
    #
    # The below will allow the Fucntion "Set-ARComputerName" to execute and close the Application.
    $ErrorButtonOK3.Add_Click({if ($_) {$ErrorForm3.Close()}})
    #
	# objForm resumes the layout of the form 
    $ErrorForm3.ResumeLayout()
	#
	# Save the initial state of the form
	$InitialFormWindowState3 = $ErrorForm3.WindowState
	#
    # Load event to correct the initial state of the form
    $ErrorForm3.add_Load($ErrorForm3_StateCorrection_Load)
    #	
    # Clean up the control events
    $ErrorForm3.add_FormClosed($ErrorForm3_Cleanup_FormClosed)
	#
    # Show the Form
    return $ErrorForm3.ShowDialog()
    #
} ### End function Load-ErrorForm3
    #
#######################################################################################################################
    #
    # Script behind the Text Box and Group Box thats sets the ARComputername.
    #
    # The below function will set the $ARComputerName varriable and only if it has a length of 8 characters.
    #
Function Set-ARComputerName { <# Start Function Set-ARComputerName #>
        IF ($TBComputerName.Text.Length -ne 8) { <# Start IF #1 #>
            Write-Host "Start If #1"
            Load-ErrorForm1
            MakeNewForm
        } <# End IF #1 #> elseIF ($TBComputerNameConfirm.Text.Length -ne 8) { <# Start elseIF #1 #>
            Write-Host "Start elseIF #1"
            Load-ErrorForm1
            MakeNewForm
        } <# End elseIF #1 #> else { <# Start else #1 #>
            $1ARComputerName = $TBComputerName
            $2ARComputerName = $1ARComputerName.Text.Replace("[","").Replace("]","").Replace(":","").Replace(";","").Replace("|","").Replace("=","").Replace("+","").Replace("*","").Replace("?","").Replace("<","").Replace(">","").Replace("/","").Replace("\","").Replace(",","")
            $3ARComputerName = $2ARComputerName.insert(0,"D")
            $1ARComputerNameConfirm = $TBComputerNameConfirm
            $2ARComputerNameConfirm = $1ARComputerNameConfirm.Text.Replace("[","").Replace("]","").Replace(":","").Replace(";","").Replace("|","").Replace("=","").Replace("+","").Replace("*","").Replace("?","").Replace("<","").Replace(">","").Replace("/","").Replace("\","").Replace(",","")
            $3ARComputerNameConfirm = $2ARComputerNameConfirm.insert(0,"D")
            Write-Host "LocationID: $2ARComputerName"
            Write-Host "Addind D to the computer name"
        IF ($2ARComputerName -ne $2ARComputerNameConfirm) { <# Start IF #2 #>
            Write-Host "Start IF #2"
            Write-Host "$2ARComputerNameConfirm is not the same as $2ARComputerName"
            Load-ErrorForm2
            MakeNewForm
         } <# End IF #2 #> elseIF ($comboBox1.SelectedItem -eq $null) { <# Start elseIF #2 #>
            Write-Host "Start elseIF #2"
            Write-Host "comboBox1 SelectedItem = False"
            Write-Host "You did not make a Selection."
            Load-ErrorForm3
            MakeNewForm
        } <# End elseIF #2 #> else { <# Start else #2 #>
            Write-Host "comboBox1 SelectedItem = True"
            $4ARComputerName = $3ARComputerName.insert(9,$comboBox1.SelectedItem)
            $4ARComputerNameConfirm = $3ARComputerNameConfirm.insert(9,$comboBox1.SelectedItem)
            Write-Host "LocationID + D + Combo Box Selected Item: $4ARComputerNameConfirm"
            Write-Host "$4ARComputerNameConfirm Matches $4ARComputerName"
            Write-Host "NAMING YOUR PC"
            Write-Host "your computer name has now been set to: $4ARComputerNameConfirm"
            Write-Host "The OK Button is now Enabled, and when clicked will close the form."
            #RENAME-COMPUTER -NewName $4ARComputerName
}  <# End else #1 #>
}  <# End else #2 #>
}  <# END Function Set-ARComputerName #>
    #
#######################################################################################################################
    # objForm Code
    #
    $objForm.Controls.Add($PCCBLabel)
    $objForm.Controls.Add($comboBox1)
    $objForm.Controls.Add($TBComputerName)
    $objForm.Controls.Add($TBComputerNameConfirm)
    $objForm.Controls.Add($LocationIDLabel) 
    $objForm.Controls.Add($ConfirmIDLabel)
	$objForm.Controls.Add($objLabel)
	$objForm.Controls.Add($ButtonOK)
    $objForm.SuspendLayout()
	$objForm.AcceptButton = $ButtonOK
	$objForm.AutoScaleDimensions = '96, 96'
	$objForm.AutoScaleMode = 'Dpi'
    $objForm.Topmost = $True
    $objForm.Add_Shown({$objForm.Activate()})
    $objForm.BackgroundImageLayout = 'Center'
	$objForm.ClientSize = '506, 322'
	$objForm.ControlBox = $False
	$objForm.Font = 'Microsoft Sans Serif, 12pt, style=Bold'
	$objForm.FormBorderStyle = 'FixedDialog'
	$objForm.Margin = '4, 5, 4, 5'
	$objForm.MaximizeBox = $False
	$objForm.MinimizeBox = $False
	$objForm.Name = 'objForm'
	$objForm.ShowIcon = $False
	$objForm.SizeGripStyle = 'Hide'
	$objForm.StartPosition = 'CenterScreen'
	$objForm.Text = 'X IT - Retail Application Support'
	#
    # The below Will enable the "form varriable" within the () to load also. EXAMPLE: $objForm_Load = {This code will now execute}
    $objForm.add_Load($objForm_Load) 
	#
	# objForm.BackGroundImage Start
	#
    $objForm.BackgroundImage = [System.Convert]::FromBase64String('IMAGE CODE HERE')
    #
	# objForm.BackGroundImage End
	#
    # TBComputerName "TextBoxComputerName" this is where the AR Location ID is entered by the user. 
    #
    $TBComputerName.Size = '339, 62'
    $TBComputerName.Location = '100, 40'
    $TBComputerName.TabIndex = "1"
    $TBComputerName.Font = 'Microsoft Sans Serif, 20pt, style=Bold'
    $TBComputerName.MaxLength = 8
    $TBComputerName.Name = 'TBComputerName'
    $TBComputerName.AcceptsReturn = $True
    #
    # This Instructs the $TBComputerName to only to allow numerical characters AND moves the cursor back to the Begining of the text box.
    $TBComputerName.Add_TextChanged({
        $this.Text = $this.Text -replace '\D'
        $this.Select($this.Text.Length, 0);})
    #
    # $TBComputerNameConfirm "TextBoxComputerNameConfirmation" this is where the AR Location ID is entered by the user the second time. 
    #
    $TBComputerNameConfirm.Size = '339, 62'
    $TBComputerNameConfirm.Location = '100, 80'
    $TBComputerNameConfirm.TabIndex = "2"
    $TBComputerNameConfirm.Font = 'Microsoft Sans Serif, 20pt, style=Bold'
    $TBComputerNameConfirm.MaxLength = 8
    $TBComputerNameConfirm.Name = 'TBComputerNameConfirm'
    $TBComputerNameConfirm.AcceptsReturn = $True
    #
    # This Instructs the $TBComputerName to only to allow numerical characters AND moves the cursor back to the Begining of the text box.
    $TBComputerNameConfirm.Add_TextChanged({
        $this.Text = $this.Text -replace '\D'
        $this.Select($this.Text.Length, 0);})
    #
	# objLabel ' Please Enter Your X Retail Location ID Number '
	#
	$objLabel.AutoSize = $True
	$objLabel.BackColor = 'Transparent'
	$objLabel.Font = 'Microsoft Sans Serif, 14pt, style=Bold'
	$objLabel.Location = '-5, 9'
	$objLabel.Margin = '4, 0, 4, 0'
	$objLabel.Name = 'objLabel'
	$objLabel.Size = '510, 24'
	$objLabel.Text = ' Please Enter Your X Retail Location ID Number '
    #
    # LocationIDLabel ' ( Location ID ) '
	#
	$LocationIDLabel.AutoSize = $True
	$LocationIDLabel.BackColor = 'Transparent'
	$LocationIDLabel.Font = 'Microsoft Sans Serif, 8pt, style=Bold'
	$LocationIDLabel.Location = '20, 50'
	$LocationIDLabel.Margin = '4, 0, 4, 0'
	$LocationIDLabel.Name = 'LocationIDLabel'
	$LocationIDLabel.Size = '100, 24'
	$LocationIDLabel.Text = ' Location ID : '
    #
    # ConfirmIDLabel ' ( Confirm ) '
	#
	$ConfirmIDLabel.AutoSize = $True
	$ConfirmIDLabel.BackColor = 'Transparent'
	$ConfirmIDLabel.Font = 'Microsoft Sans Serif, 8pt, style=Bold'
	$ConfirmIDLabel.Location = '20, 100'
	$ConfirmIDLabel.Margin = '4, 0, 4, 0'
	$ConfirmIDLabel.Name = 'ConfirmIDLabel'
	$ConfirmIDLabel.Size = '100, 24'
	$ConfirmIDLabel.Text = ' Confirm : '
    #
	# ButtonOK "OK Button"
	#
	$ButtonOK.Anchor = 'Bottom, Right'
	$ButtonOK.DialogResult = 'OK'
	$ButtonOK.Location = '369, 273'
	$ButtonOK.Margin = '4, 5, 4, 5'
	$ButtonOK.Name = 'ButtonOK'
	$ButtonOK.Size = '124, 35'
	$ButtonOK.TabIndex = 4
	$ButtonOK.Text = 'OK'
	$ButtonOK.UseVisualStyleBackColor = $True
    #
    # $comboBox1
    #
    $comboBox1.Location = '280, 120'
    $comboBox1.Size = '160, 35'
	$comboBox1.Margin = '4, 5, 4, 5'
	$comboBox1.Name = 'comboBox1'
	$comboBox1.TabIndex = 3
	$comboBox1.Font = 'Microsoft Sans Serif, 8pt, style=Bold'
    #
    # How to Prevent typing into a combobox set the DropDownStyle property.
    $comboBox1.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    #
    # How to Clean up the combobox.
    $comboBox1.Items.Clear()
    #
    # How to sort data of the combobox.
    $comboBox1.Sorted = $true
    #
    # comboBox1 Drop Down List below.
    #
    $ComputerNames = $comboBox1.Items.Add("PC1")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC2")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC3")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC4")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC5")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC6")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC7")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC8")|Out-Null
    $ComputerNames = $comboBox1.Items.Add("PC9")|Out-Null
    #
    # PCCBLabel ' PC Number : ' PC comboBox1 Label.
	# 
	$PCCBLabel.AutoSize = $True
	$PCCBLabel.BackColor = 'Transparent'
	$PCCBLabel.Font = 'Microsoft Sans Serif, 8pt, style=Bold'
	$PCCBLabel.Location = '200, 120'
	$PCCBLabel.Margin = '4, 0, 4, 0'
	$PCCBLabel.Name = 'ConfirmIDLabel'
	$PCCBLabel.Size = '100, 24'
	$PCCBLabel.Text = ' PC Number : '
    #
    # The below will allow the Fucntion "Set-ARComputerName" to execute and close the Application.
    $ButtonOK.Add_Click({Set-ARComputerName})
    #
	# objForm resumes the layout of the form
    $objForm.ResumeLayout()
	#
	# Save the initial state of the form
	$InitialFormWindowState = $objForm.WindowState
	#
    # Load event to correct the initial state of the form
	$objForm.add_Load($objForm_StateCorrection_Load)
    #	
    # Clean up the control events
    $objForm.add_FormClosed($objForm_Cleanup_FormClosed)
	#
    # Show the Form
    return $objForm.ShowDialog()
    #
    #
} ### End Function Load-objForm

CLS
Load-objForm 