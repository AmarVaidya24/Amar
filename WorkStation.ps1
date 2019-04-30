


#----------------------------------------------
#region Application Functions
#----------------------------------------------

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Show-WorkStation_Tools_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formWorkStationToolsV10 = New-Object 'System.Windows.Forms.Form'
	$groupbox3 = New-Object 'System.Windows.Forms.GroupBox'
	$Outputrichtextbox1 = New-Object 'System.Windows.Forms.RichTextBox'
	$groupbox2 = New-Object 'System.Windows.Forms.GroupBox'
	$RadioInternetAccess = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonRepairOutlookPST = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonRepairOutlookProfile = New-Object 'System.Windows.Forms.RadioButton'
	$buttonResolve = New-Object 'System.Windows.Forms.Button'
	$radiobuttonCreateRegistryValue = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonNetworkLinkDisconnec = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonGPOIssue = New-Object 'System.Windows.Forms.RadioButton'
	$radiobuttonDNSIssue = New-Object 'System.Windows.Forms.RadioButton'
	$statusbar1 = New-Object 'System.Windows.Forms.StatusBar'
	$groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
	$ConnectToComputer = New-Object 'System.Windows.Forms.Button'
	$ComputerNameInputTextBox = New-Object 'System.Windows.Forms.TextBox'
	$labelEnterComputerName = New-Object 'System.Windows.Forms.Label'
	$error_computer_name = New-Object 'System.Windows.Forms.ErrorProvider'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	## Variable Decleartion ##
	$global:LogFileFullName = "C:\Temp\WorkStationTools\Logs.txt"
	
	## Function Declearationn ##
	Function Write-Log
	{
		Param (
			[Parameter(Mandatory = $false)]
			[string]$LogString,
			[Parameter(Mandatory = $false)]
			[bool]$DisplayTimestamp = $true,
			[Parameter(Mandatory = $false)]
			[string]$ForegroundColor = $null
		)
		$LogString = $LogString + "`n"
		$Outputrichtextbox1.Text += $LogString
		
		if ($LogString)
		{
			if ($DisplayTimestamp)
			{
				$LogString = "[$(Get-Date -Format G)]: $LogString"
			}
		}
		else
		{
			$LogString = "[$(Get-Date -Format G)]: "
		}
		$LogString | Out-File $global:LogFileFullName -Append
		#Add-content -Path $global:LogFileFullName -value $LogString
	} # End Function Write-Log
	
	$formWorkStationToolsV10_Load = {
		
		$script:computername = $env:COMPUTERNAME
		$ComputerNameInputTextBox.Text = $script:computername
		$buttonResolve.Enabled = $false
		
		try
		{
			if (!(Test-Path $global:LogFileFullName))
			{
				New-Item -Path $global:LogFileFullName -ItemType File -Force | Out-Null
			}
			$Outputrichtextbox1.Text += "Logs are generated at location $global:LogFileFullName `n"
		}
		catch
		{
			$statusbar1.Text = "Not able to generate log file."
			$Outputrichtextbox1.Text += "Not able to generate log file."
			$Outputrichtextbox1.Text += "Tool will process without any log generation."
			$Outputrichtextbox1.Text += "Please check permissions at location $global:LogFileFullName"
		}
	}
	
	$groupbox1_Enter={
		
	}
	
	$ComputerNameInputTextBox_TextChanged={	
		
	}
	
	$ConnectToComputer_Click = {
		
		$computername = $ComputerNameInputTextBox.Text
		$ConnectToComputer.Enabled = $false
		$error_computer_name.Clear()
		
		$statusbar1.Text = "Trying to connect to computer $($computername). Please wait."
		Write-Log ""
		Write-Log "******* Trying to connect to computer $($computername) *******"
		
		# trying to connect to computer.
		try
		{
			Test-Connection -ComputerName $computername -ErrorAction Stop -Count 4
			$buttonResolve.Enabled = $true
			
			$statusbar1.Text = "Successfully connected to computer $($computername)"
			Write-Log "******* Successfully connected to computer $($computername) *******"
		}
		catch
		{
			$error_computer_name.SetIconAlignment($ConnectToComputer, 'MiddleLeft')
			$error_computer_name.SetError($ConnectToComputer, $($_.Exception.Message))
			
			$statusbar1.Text = "$($computername) : $($_.Exception.Message)."
			Write-Log "$($computername) : $($_.Exception.Message)."
			
			$buttonResolve.Enabled = $false
			
		}
		$ConnectToComputer.Enabled = $true
	}
	
	$statusbar1_PanelClick=[System.Windows.Forms.StatusBarPanelClickEventHandler]{
	#Event Argument: $_ = [System.Windows.Forms.StatusBarPanelClickEventArgs]
		
	}
	
	$buttonResolve_Click = {
		
		$logs = $null
		$buttonResolve.Enabled = $false
		$computername = $ComputerNameInputTextBox.Text
		Write-Log ""
		
		if ($radiobuttonDNSIssue.Checked)
		{
			$statusbar1.Text = "Trying to resolve DNS Issue."
			Write-Log $statusbar1.Text
			$ErrorActionPreference = "SilentlyContinue"
			
			$DNSIssue1 = .\PsExec.exe \\$computername -accepteula cmd /c "Ipconfig /flushdns"
			Write-Log $DNSIssue1
			Write-Log "DNS Flushing Completed."
			
			$DNSIssue2 = .\PsExec.exe \\$computername -accepteula cmd /c "Ipconfig /registerdns"
			Write-Log $DNSIssue2
			Write-Log "DNS Registration Completed."
			
			$ErrorActionPreference = "Continue"
			Write-Log "DNS Flushing/Registration Completed."
			$statusbar1.Text = "DNS Flushing/Registration Completed."
		}
		
		if ($radiobuttonGPOIssue.Checked)
		{
			$statusbar1.Text = "Trying to resolve GPO Issue."
			Write-Log $statusbar1.Text
			
			$ErrorActionPreference = "SilentlyContinue"
			if (Test-Path "C:\ProgramData\Microsoft\Group Policy\History")
			{
				$DeleteGOP1 = .\PsExec.exe \\$computername -accepteula cmd /c "rmdir /s /q ""C:\ProgramData\Microsoft\Group Policy\History"""
				Write-Log "Deleted folder from path 'C:\ProgramData\Microsoft\Group Policy\History'."
			}
			else
			{
				Write-Log "Folder not found on path 'C:\ProgramData\Microsoft\Group Policy\History'."
			}
			if (Test-Path "C:\Windows\security\database\secedit.sdb")
			{
				$DeleteGPO2 = .\PsExec.exe \\$computername -accepteula cmd /c "del /f /q C:\Windows\security\database\secedit.sdb"
				Write-Log "Deleted file from path 'C:\Windows\security\database\secedit.sdb'."
			}
			else
			{
				Write-Log "File not found on path 'C:\Windows\security\database\secedit.sdb'."
			}
			$GPOUpdate = .\PsExec.exe \\$computername -accepteula cmd /c "gpupdate /force"
			
			Write-Log "Updated Group Policy Successfully."
			$statusbar1.Text = "Updated Group Policy Successfully."
			$ErrorActionPreference = "Continue"
		}
		
		if ($radiobuttonNetworkLinkDisconnec.Checked)
		{
			$statusbar1.Text = "Trying to modify network power setting on device: $computername."
			Write-Log $statusbar1.Text
			
			if ($computername -eq ($env:COMPUTERNAME))
			{
				try
				{
					$namespace = "root\WMI"
					Get-WmiObject Win32_NetworkAdapter -filter "AdapterTypeId=0" | % {
						$strNetworkAdapterID = $_.PNPDeviceID.ToUpper()
						Get-WmiObject -class MSPower_DeviceEnable -Namespace $namespace | % {
							if ($_.InstanceName.ToUpper().startsWith($strNetworkAdapterID))
							{
								$_.Enable = $false
								$_.Put() | Out-Null
								$statusbar1.Text = "Successfully Disabled `"Allow the computer to turn off this device to save power`" setting."
								Write-Log $statusbar1.Text
							}
						}
					}
				}
				catch
				{
					$statusbar1.Text = "ERROR: Not able to modify network power setting on this device"
					Write-Log $statusbar1.Text
				}
			}
			else
			{
				$statusbar1.Text = "ERROR: This Tool cannot modify network power setting on Remote Machines."
				Write-Log $statusbar1.Text
			}
		}
		
		if ($radiobuttonCreateRegistryValue.Checked)
		{
			
			$statusbar1.Text = "Trying to modify registry setting on $ComputerName"
			$Logs = ""
			$Hive = "LocalMachine"
			$Key = "System\CurrentControlSet\Services\SboxTeamDrv\Parameters"
			$Name = "DirctlType"
			$Value = "1"
			$Type = "DWORD"
			$Force = $true
			$RegStopFlag = 0 

			$statusbar1.Text = "Trying to Create Registry Entry for SboxTeamDrv."
			Write-Log $statusbar1.Text
			
			try
			{
				$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
				#Open the targeted remote registry key/subkey as read/write
				$regKey = $reg.OpenSubKey($Key, $true)
				
				#Since trying to open a regkey doesn't error for non-existent key, let's sanity check
				#Create subkey if parent exists. If not, exit.
				If ($regkey -eq $null)
				{ 
					Write-Log "Specified key $Key does not exist."
					$parentKey1 = "System\CurrentControlSet\Services\SboxTeamDrv"
					$childKey1 = "Parameters"
					
					$parentKey2 = "System\CurrentControlSet\Services"
					$childKey2 = "SboxTeamDrv"
					
					# Creating subkey:SboxTeamDrv in System\CurrentControlSet\Services			
					try
					{
						$regtemp = $reg.OpenSubKey($parentKey2, $true)
					}
					catch
					{
						$statusbar1.Text = "$parentKey2 doesn't exist in $Hive or you don't have access to it. Exiting."
						Write-Log $statusbar1.Text
					    $RegStopFlag = 1 
					}
					If ($regtemp -ne $null)
					{
						Write-Log "Creating ChildKey: SboxTeamDrv."
						try
						{
							$regtemp.CreateSubKey($childKey2) | Out-Null
						}
						catch
						{
							$statusbar1.Text = "Could not create $childKey2 in $parentKey2. You may not have permission. Exiting."
							Write-Log $statusbar1.Text
							$RegStopFlag = 1 
						}
						
						$regKey = $reg.OpenSubKey($Key, $true)
					}
					else
					{
						$statusbar1.Text = "$parentKey2 doesn't exist. Exiting."
						Write-Log $statusbar1.Text
						$RegStopFlag = 1 
					}
					
					# Creating subkey:Parameters in System\CurrentControlSet\Services\SboxTeamDrv			
					try
					{
						$regtemp = $reg.OpenSubKey($parentKey1, $true)
					}
					catch
					{
						$statusbar1.Text = "$parentKey1 doesn't exist in $Hive or you don't have access to it. Exiting."
						Write-Log $statusbar1.Text
						$RegStopFlag = 1 
					}
					If (($regtemp -ne $null) -and ($RegStopFlag -ne 1))
					{
						Write-Log "Creating ChildKey: Parameters."
						try
						{
							$regtemp.CreateSubKey($childKey1) | Out-Null
						}
						catch
						{
							$statusbar1.Text = "Could not create $childKey1 in $parentKey1. You may not have permission. Exiting."
							Write-Log $statusbar1.Text
							break
						}
						
						$regKey = $reg.OpenSubKey($Key, $true)
					}
					else
					{
						$statusbar1.Text = "$parentKey1 doesn't exist. Exiting."
						Write-Log $statusbar1.Text
					}
					
				}
				
				#Cleanup temp operations
				try
				{
					$regtemp.close()
					Remove-Variable $regtemp, $parentKey1, $childKey1, $parentKey2, $childKey2
				}
				catch
				{
					#Nothing to do here. Just suppressing the error if $regtemp was null
				}
				
				#If we got this far, we have the key, create or update values
				
				$KeyValue = $regkey.GetValue("DirctlType")
				if ($KeyValue -eq 1)
				{
					$statusbar1.Text = "Value of registry key:DirctlType at path: 'System\CurrentControlSet\Services\SboxTeamDrv\Parameters' is already: 1"
					Write-Log $statusbar1.Text
				}
				else
				{
					$regKey.Setvalue("$Name", "$Value", "$Type")
					$KeyValue = $regkey.GetValue("DirctlType")
					$statusbar1.Text = "Value of registry key: DirctlType at path: 'System\CurrentControlSet\Services\SboxTeamDrv\Parameters' set to: $KeyValue"
					Write-Log $statusbar1.Text
				}
				
				#Cleanup all variables
				try
				{
					$regKey.close()
					Remove-Variable $Hive, $Key, $Name, $Value, $Force, $reg, $regKey, $yes, $no, $caption, $message, $result
				}
				catch
				{
					#Nothing to do here. Just suppressing the error if any variable is null
				}
				
			}
			catch
			{
				$statusbar1.Text = "Please ensure remote registry service is running and you have administrative access to $ComputerName."
				Write-Log $statusbar1.Text
			}
		}

		if ($radiobuttonRepairOutlookProfile.Checked)
		{
			$statusbar1.Text = "Trying to resolve Outlook Profile Issue."
			Write-Log $statusbar1.Text
			
			# $Loglevel = @("INFO","WARNING","ERROR","FATALERROR", "DEBUG")
			
			
			$CheckOutlookInstallationStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE" -ErrorAction SilentlyContinue).Path
			
			if ($CheckOutlookInstallationStatus)
			{
				function Format-Message
				(
					[string]$Message,
					[string]$level
				)
				{
					
					return "{0}`t{1}`t{2}" -f ((Get-Date).ToString(), $level, $Message)
					
				}
				
				function Show-Msgbox
				
				([string]$Message,
					[int]$Btn,
					[int]$Icon)
				{
					#$Icon = 32	=> IconQuestion; $Icon = 64 => IconInformation 
					#$Btn = 4  => Yes / No btn ; $Btn = 0 => ok only
					
					[System.Windows.Forms.MessageBox]::Show($Message, $Messages."TITLE_$Lang", $Btn, $Icon)
					
					
					
				}
				
				
				#Get root folder of user profile and set other variables needed
				$HomeDrive = (Get-Childitem env:HOMEDRIVE).Value
				$HomePath = (Get-Childitem env:HOMEPATH).Value
				$RoamingMicrosoft = $HomeDrive + $HomePath + '\AppData\Roaming\Microsoft'
				$SystemDrive = (Get-Childitem env:SystemDrive).Value
				$strName = $env:username
				$Logfile = $RoamingMicrosoft + "\Repair_OutlookProfile.log"
				#$OriginalPolicySettings = Get-ItemProperty "hkcu:\Software\Policies\Microsoft\Office\12.0\Outlook\Security" -ErrorAction SilentlyContinue
				
				
				# Get user language
				[string]$Lang = (Get-ItemProperty -Path "HKCU:Control Panel\Desktop" -Name 'PreferredUILanguages' -ErrorAction SilentlyContinue).PreferredUILanguages
				If ($Lang -ne '') { $Lang = $Lang.SubString(0, 2).ToUpper() }
				
				If ($lang -ne 'FR' -and $lang -ne 'EN' -and $lang -ne 'ES')
				{
					Format-Message -Level '  INFO  ' -Message "Language not detected. Set to EN" | Out-File -FilePath $Logfile -Append
					$Lang = 'EN'
				}
				else
				{
					Format-Message -Level '  INFO  ' -Message "Language detected: $Lang" | Out-File -FilePath $Logfile -Append
				}
				
				$Messages = @{
					TITLE_FR   = "Réparation du profil Outlook";
					CLOSE_FR   = "Cette action va entrainer la fermeture d'Outlook et de Microsoft Lync";
					CANCEL_FR  = "L'action a été annulée. Relancez le script plus tard pour réparer le profil";
					INIT_FR    = "Initialisation des objets Outlook. Cela prendra une trentaine de secondes";
					INIT2_FR   = "Re-initialisation d'Outlook. Cela prendra une trentaine de secondes";
					ERROR_FR   = "Le script s'est terminé avec des erreurs. Contactez le support si les lenteurs Outlook persistent";
					ERROR2_FR  = "Le script s'est terminé avec des erreurs. Contactez le support si Outlook ne redémarre pas correctement";
					END_FR	   = "Fin de traitement. Vous pouvez utiliser Outlook normalement";
					TITLE_EN   = "Repair of Outlook Profile";
					CLOSE_EN   = "This action will close Outlook and Lync";
					CANCEL_EN  = "Action has been canceled. Rerun the script again later to repair the profile";
					INIT_EN    = "Initialization of Outlook objects. This will take about 30 seconds";
					INIT2_EN   = "Initialization of Outlook. This will take about 30 seconds";
					ERROR_EN   = "Script ends with errors. Contact support team if slowness still appears";
					ERROR2_EN  = "Script ends with errors. Contact support team if Outlook does not start correctly";
					END_EN	   = "End of treament. You can use Outlook normally";
					TITLE_ES   = "Reparación del perfil Outlook";
					CLOSE_ES   = "Esta acción va a cerrar Outlook y Lync";
					CANCEL_ES  = "La acción fue cancelada. Reinicie el script más tarde para reparar el perfil";
					INIT_ES    = "Inicialización de los elementos de Outlook. Tomará unos treinta segundos";
					INIT2_ES   = "Re-Inicialización de Outlook. Tomará unos treinta segundos";
					ERROR_ES   = "El script terminó con errores. Contactar con el soporte si persisten los retrasos de Outlook";
					ERROR2_ES  = "El script terminó con errores. Contactar con el soporte si Outlook no se inicia correctamente";
					END_ES	   = "Final del tratamiento. Puede utilizar Outlook normalmente"
				}
				
				
				# load object library Windows.Forms
				[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
				
				$tmp = "CLOSE_$Lang"
				$Reponse = Show-Msgbox -Message $Messages."CLOSE_$Lang" -Btn 4 -Icon 32
				
				if ($Reponse -eq "No")
				{
					
					Show-Msgbox -Message $Messages."CANCEL_$Lang" -Btn 0 -Icon 64
					Return 0
					
				}
				
				
				Format-Message -Level '  INFO  ' -Message "Starting new session of script" | Out-File -FilePath $Logfile -Append
				
				#close outlook.exe and Lync.exe
				Get-Process OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force
				Get-Process lync -ErrorAction SilentlyContinue | Stop-Process -Force
				
				#Format-Message -Level '  INFO  ' -Message "Closing Outlook and set security policy to low in hkcu:\Software\Policies\Microsoft\Office\12.0\Outlook\Security" | Out-File -FilePath $Logfile -Append
				Format-Message -Level '  INFO  ' -Message "Closing Outlook" | Out-File -FilePath $Logfile -Append
				
				#Create C:\local\Save if it doesn't exists
				if (!(Test-Path "$SystemDrive\Local\Save")) { New-Item "$SystemDrive\Local\Save" -type directory }
				if (!(Test-Path "$RoamingMicrosoft\Save")) { New-Item "$RoamingMicrosoft\Save" -type directory }
				
				if ((Test-Path "$RoamingMicrosoft\Save\Outlook")) { Remove-Item "$RoamingMicrosoft\Save\Outlook" -Force -recurse }
				if ((Test-Path "$RoamingMicrosoft\Save\Signatures")) { Remove-Item "$RoamingMicrosoft\Save\Signatures" -Force -recurse }
				if ((Test-Path "$RoamingMicrosoft\Save\Templates")) { Remove-Item "$RoamingMicrosoft\Save\Templates" -Force -recurse }
				
				Format-Message -Level '  INFO  ' -Message "Copy Outlook data to $SystemDrive\Local\Save" | Out-File -FilePath $Logfile -Append
				
				$error.clear()
				
				#Backup Outlook Profile in C:\local\Save before starting proc
				if ((Test-Path "$RoamingMicrosoft\Outlook")) { Copy-Item "$RoamingMicrosoft\Outlook" "$SystemDrive\Local\Save" -recurse -Force }
				#if ( (Test-Path "$RoamingMicrosoft\Outlook")) { Copy-Item "$RoamingMicrosoft\Outlook" "$RoamingMicrosoft\Save" -recurse }
				if ((Test-Path "$RoamingMicrosoft\Signatures")) { Copy-Item "$RoamingMicrosoft\Signatures" "$SystemDrive\Local\Save" -recurse -Force }
				#if ( (Test-Path "$RoamingMicrosoft\Signatures")) { Copy-Item "$RoamingMicrosoft\Signatures" "$RoamingMicrosoft\Save" -recurse }
				if ((Test-Path "$RoamingMicrosoft\Templates")) { Copy-Item "$RoamingMicrosoft\Templates" "$SystemDrive\Local\Save" -recurse -Force }
				#if ( (Test-Path "$RoamingMicrosoft\Templates")) { Copy-Item "$RoamingMicrosoft\Templates" "$RoamingMicrosoft\Save" -recurse }
				
				if ($error.Exception -ne $null)
				{
					$trycatcherror = $error[0].Exception
					Format-Message -Level '  ERROR  ' -Message "Error occured during Outlook backup : $trycatcherror" | Out-File -FilePath $Logfile -Append
					Show-Msgbox -Message $Messages."ERROR_$Lang" -Btn 0 -Icon 64
					return 0; # end
				}
				
				
				#restarting Outlook
				$OutlookPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE" -ErrorAction SilentlyContinue).Path + "Outlook.exe"
				
				Format-Message -Level '  INFO  ' -Message "Restarting Outlook from $OutlookPath" | Out-File -FilePath $Logfile -Append
				
				Write-Host $Messages."INIT_$Lang" -foregroundcolor green
				
				Start-Process -FilePath $OutlookPath -WindowStyle Maximized
				
				#Minimize Outlook Window after 3 seconds
				sleep -sec 3
				$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
				Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
				$PSId = @(Get-Process OUTLOOK -ErrorAction SilentlyContinue)[0].MainWindowHandle
				If ($PSId -ne $NULL) { [Win32.NativeMethods]::ShowWindowAsync($PSId, 2) }
				
				#Wait 5 seconds before continue
				Start-Sleep -s 5
				
				#Clearing error stack
				$error.clear()
				
				try
				{
					#init Outlook App
					Add-Type -assembly "Microsoft.Office.Interop.Outlook"
					$olFolderInbox = 6
					$outlook = New-Object -ComObject outlook.application
					$namespace = $Outlook.GetNameSpace('MAPI')
					$explorer = $Outlook.ActiveExplorer()
					$ns = $explorer.Session
					
					$DefaultProfileName = $outlook.Application.DefaultProfileName
					
					#Get Outlook short version number (used for registries paths)
					$OutlookVersion = $outlook.Application.Version
					switch -wildcard ($OutlookVersion)
					{
						"12*" { $ShortOutlookVersion = "12.0" }
						"15*" { $ShortOutlookVersion = "15.0" }
						default { $ShortOutlookVersion = "12.0" }
					}
					Format-Message -Level '  INFO  ' -Message "Outlook version : $OutlookVersion" | Out-File -FilePath $Logfile -Append
					Format-Message -Level '  INFO  ' -Message "Outlook short version : $ShortOutlookVersion" | Out-File -FilePath $Logfile -Append
					
					
				}
				Catch [system.exception]
				{
					$trycatcherror = $error[0].Exception
					Format-Message -Level '  ERROR  ' -Message "Error occured during Outlook initalization : $trycatcherror" | Out-File -FilePath $Logfile -Append
					Show-Msgbox -Message $Messages."ERROR_$Lang" -Btn 0 -Icon 64
					return 0; # end
				}
				
				if ($ns -eq $null)
				{
					#just a retry... never known, it may works on a mistake :)
					Start-Sleep -s 10
					$explorer = $Outlook.ActiveExplorer()
					$ns = $explorer.Session
				}
				
				
				#if $ns is null no way to list PST...
				if ($ns -eq $null)
				{
					Format-Message -Level '  ERROR  ' -Message "Error occured during Outlook initalization : unable to get Outlook.ActiveExplorer().Session" | Out-File -FilePath $Logfile -Append
					Show-Msgbox -Message $Messages."ERROR_$Lang" -Btn 0 -Icon 64
					return 0;
				}
				
				$ftype = [Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox
				
				#set 
				#$inbox = $namespace.getDefaultFolder($olFolderInbox )
				$inbox = $namespace.getDefaultFolder($ftype)
				$stores = $outlook.Stores
				
				#create custom array to store PST infos
				$ArchiveList = @()
				
				#Save Pst info to an array
				$ArchiveList = $ns.Stores | ? { ($_.IsDataFileStore -eq $TRUE) -and ($_.FilePath.EndsWith(".pst")) } | Select-Object DisplayName, FilePath
				$OSTPath = $ns.Stores | ? { ($_.IsDataFileStore -eq $TRUE) -and ($_.FilePath.EndsWith(".ost")) } | Select-Object DisplayName, FilePath
				
				
				#Close Outlook App and release object
				$outlook.Quit()
				[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook)
				
				#kill lync if running
				Get-Process lync -ErrorAction SilentlyContinue | Stop-Process -Force
				
				Format-Message -Level '  INFO  ' -Message "Collecting Mounted PST : $ArchiveList" | Out-File -FilePath $Logfile -Append
				
				#Wait 5 seconds before continue
				Start-Sleep -s 5
				
				#Rename Old OST
				#$CurrentDatebkp = get-date -f MM-dd-yyyy_HH_mm_ss
				$OSTPath | foreach {
					
					$CurrentDatebkp = $_.FilePath + "_" + (get-date -f MM-dd-yyyy_HH_mm_ss) + ".bkp"
					Format-Message -Level '  INFO  ' -Message "Renaming OST to : $CurrentDatebkp" | Out-File -FilePath $Logfile -Append
					Rename-Item $_.FilePath  $CurrentDatebkp
				}
				
				#move previous backup of profile (if any)
				if ((Test-Path "$SystemDrive\Local\Save\OutlookProfile_$strName__.reg")) { Remove-Item "$SystemDrive\Local\Save\OutlookProfile_$strName__.reg" -Force }
				if ((Test-Path "$SystemDrive\Local\Save\OutlookProfile_$strName.reg")) { Rename-Item "$SystemDrive\Local\Save\OutlookProfile_$strName.reg" "$SystemDrive\Local\Save\OutlookProfile_$strName__.reg" }
				
				#Define the profiles Regkey depending on the Outlook Version
				If ($ShortOutlookVersion -eq "12.0")
				{
					$profilesRegKey = "Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"
					Reg.exe export "HKCU\$profilesRegKey\$DefaultProfileName" "$SystemDrive\Local\Save\OutlookProfile_$strName.reg"
				}
				Else
				{
					$profilesRegKey = "Software\Microsoft\Office\$ShortOutlookVersion\Outlook\Profiles"
					Reg.exe export "HKCU\$profilesRegKey\$DefaultProfileName" "$SystemDrive\Local\Save\OutlookProfile_$strName.reg"
				}
				
				Format-Message -Level '  INFO  ' -Message "Removing Outlook profile in registry : HKCU\$profilesRegKey\$DefaultProfileName" | Out-File -FilePath $Logfile -Append
				
				#Backup outlook profile settings (in registry)
				#Reg.exe export "HKCU\$profilesRegKey\$DefaultProfileName" "$SystemDrive\Local\Save\OutlookProfile_$strName.reg"
				
				
				#Disabled ?
				#Now Delete profile information
				Remove-Item -Path "HKCU:\$profilesRegKey\$DefaultProfileName" -Recurse
				
				#And create new profile and set it as default
				New-Item -Path "HKCU:\$profilesRegKey\$DefaultProfileName"
				New-Item -Path "HKCU:\$profilesRegKey\$DefaultProfileName\0a0d020000000000c000000000000046"
				New-ItemProperty -Path "HKCU:\$profilesRegKey\$DefaultProfileName\0a0d020000000000c000000000000046" -Name "0003041b" -PropertyType Binary -Value ([byte[]](0xFF, 0xFF, 0xFF, 0xFF))
				New-ItemProperty -Path "HKCU:\$profilesRegKey" -Name "DefaultProfile" -value "$DefaultProfileName" -Force
				#>
				
				#force DelegateSentItemsStyle to 1
				New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$ShortOutlookVersion\Outlook\Preferences" -Name "DelegateSentItemsStyle" -value 00000001 -PropertyType "DWord" -Force
				
				Format-Message -Level '  INFO  ' -Message "Collecting Mounted PST : $ArchiveList" | Out-File -FilePath $Logfile -Append
				
				Start-Sleep -s 10
				#Re-init Outlook App (and maximize window => user see the sync with exchange srv)
				Start-Process -FilePath $OutlookPath -WindowStyle Maximized #-ArgumentList "/profile $DefaultProfileName"
				#write-host $OutlookPath
				#Start-Process -FilePath "cmd.exe" -WindowStyle Maximized -ArgumentList "/c ""$OutlookPath"""
				
				Write-Host $Messages."INIT2_$Lang" -foregroundcolor green
				
				Start-Sleep -s 5
				
				#Minimize Outlook window
				$PSId = @(Get-Process OUTLOOK -ErrorAction SilentlyContinue)[0].MainWindowHandle
				If ($PSId -ne $NULL) { [Win32.NativeMethods]::ShowWindowAsync($PSId, 2) }
				
				Start-Sleep -s 5
				
				$outlook = New-Object -ComObject outlook.application
				$namespace = $Outlook.GetNameSpace('MAPI')
				$explorer = $Outlook.ActiveExplorer()
				$ns = $explorer.Session
				
				
				#if $ns is null no way to perform any action in Outlook...
				if ($ns -eq $null)
				{
					Format-Message -Level '  ERROR  ' -Message "Error occured during Outlook initalization : unable to get Outlook.ActiveExplorer().Session" | Out-File -FilePath $Logfile -Append
					Show-Msgbox $Messages."ERROR2_$Lang" -Btn 0 -Icon 64
					return 0;
				}
				
				#Remount PST
				$ArchiveList | foreach {
					Format-Message -Level '  INFO  ' -Message "Adding PST to profil $_" | Out-File -FilePath $Logfile -Append
					if ($_.FilePath -ne $null)
					{
						$ns.AddStore($_.FilePath)
						if (-not $?)
						{
							$Errmsg = $Error[0].Exception.Message
							Format-Message -Level 'ERROR' -Message "Error occured when script add PST : $Errmsg" | Out-File -FilePath $Logfile -Append
						}
					}
				}
				
				
				
				#Close Outlook App and release object
				$outlook.Quit()
				[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook)
				
				#Wait for Outlook to exit properly
				Start-Sleep -s 5
				
				Get-Process OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force
				Get-Process lync -ErrorAction SilentlyContinue | Stop-Process -Force
				
				if ((Test-Path "$SystemDrive\Local\Save\Outlook")) { Copy-Item "$SystemDrive\Local\Save\Outlook" "$RoamingMicrosoft" -recurse -Force }
				if ((Test-Path "$SystemDrive\Local\Save\Signatures")) { Copy-Item "$SystemDrive\Local\Save\Signatures" "$RoamingMicrosoft" -recurse -Force }
				if ((Test-Path "$SystemDrive\Local\Save\Templates")) { Copy-Item "$SystemDrive\Local\Save\Templates" "$RoamingMicrosoft" -recurse -Force }
				
				Show-Msgbox $Messages."END_$Lang" -Btn 0 -Icon 64
			}
			else
			{
				$statusbar1.Text = "Outlook don't exists on this system"
				Write-Log $statusbar1.Text
			}
		}
		
		if ($radiobuttonRepairOutlookPST.Checked)
		{
			$statusbar1.Text = "Trying to resolve Outlook PST Issue."
			Write-Log $statusbar1.Text
			
			# $Loglevel = @("INFO","WARNING","ERROR","FATALERROR", "DEBUG")
			
			$CheckOutlookInstallationStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE" -ErrorAction SilentlyContinue).Path
			
			if ($CheckOutlookInstallationStatus)
			{
				function Format-Message
				{
					Param ([string]$Message,
						[string]$level)
					
					return "{0}`t{1}`t{2}" -f ((Get-Date).ToString(), $level, $Message)
				}
				
				function Show-Msgbox
				{
					#$Icon = 32	=> IconQuestion; $Icon = 64 => IconInformation 
					#$Btn = 4  => Yes / No btn ; $Btn = 0 => ok only
					Param (
						[string]$Message,
						[int]$Btn,
						[int]$Icon)
					
					$Titre = 'Repairing PST files'
					[System.Windows.Forms.MessageBox]::Show($Message, $Titre, $Btn, $Icon)
				}
				
				$MinPSTSize = 300kb
				
				$HomeDrive = (Get-Childitem env:HOMEDRIVE).Value
				$HomePath = (Get-Childitem env:HOMEPATH).Value
				$RoamingMicrosoft = $HomeDrive + $HomePath + '\AppData\Roaming\Microsoft\Outlook'
				$Windir = (Get-Childitem env:windir).Value
				$Logfile = $RoamingMicrosoft + "\Repair_Mounted_PST.log"
				
				Format-Message -Level 'INFO' -Message "Starting new session of script" | Out-File -FilePath $Logfile -Append
				
				# load object library Windows.Forms
				[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
				
				$Reponse = Show-Msgbox -Message "This action will close Outlook and Microsoft Lync" -Btn 4 -Icon 32
				
				if ($Reponse -eq "No")
				{
					
					Show-Msgbox "The action has been canceled. Restart the script later to repair the PST" -Btn 0 -Icon 64
					Return 0
					
				}
				
				#close outlook.exe and Lync.exe
				Get-Process OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force
				Get-Process lync -ErrorAction SilentlyContinue | Stop-Process -Force
				
				$OutlookPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE" -ErrorAction SilentlyContinue).Path + "Outlook.exe"
				
				Write-Host "Initializing Outlook objects. It will take about thirty seconds." -foregroundcolor green
				
				$GetrunningProcess = Get-Process OUTLOOK -ErrorAction SilentlyContinue
				if ($GetrunningProcess -eq $null)
				{
					Start-Process -FilePath $OutlookPath -WindowStyle Maximized
				}
				
				Start-Sleep -s 3
				
				$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
				Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
				$PSId = @(Get-Process OUTLOOK -ErrorAction SilentlyContinue)[0].MainWindowHandle
				If ($PSId -ne $NULL) { [Win32.NativeMethods]::ShowWindowAsync($PSId, 2) }
				
				#init Outlook App
				try
				{
					Add-Type -assembly "Microsoft.Office.Interop.Outlook"
					$olFolderInbox = 6
					$outlook = New-Object -ComObject outlook.application;
					$namespace = $Outlook.GetNameSpace('MAPI');
					$explorer = $Outlook.ActiveExplorer()
					$ns = $explorer.Session
				}
				Catch [system.exception]
				{
					$trycatcherror = $error[0].Exception
					Format-Message -Level 'ERROR' -Message "Error occured during Outlook initalization : $trycatcherror" | Out-File -FilePath $Logfile -Append
					Show-Msgbox "The script is finished with errors. Contact support if Outlook delays persist." -Btn 0 -Icon 64
					return 0; # end
				}
				
				
				#if $ns is null no way to list PST...
				if ($ns -eq $null)
				{
					Format-Message -Level 'ERROR' -Message "Error occured during Outlook initalization : unable to get Outlook.ActiveExplorer().Session" | Out-File -FilePath $Logfile -Append
					Show-Msgbox "The script is finished with errors. Contact support if Outlook delays persist.", 0, 64
					return 0;
				}
				
				$ftype = [Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox
				$inbox = $namespace.getDefaultFolder($ftype)
				$stores = $outlook.Stores
				
				#create custom array to store PST infos
				$ArchiveList = @()
				
				#Save Pst info to an array
				$ArchiveList = $ns.Stores | ? { ($_.IsDataFileStore -eq $TRUE) -and ($_.FilePath.EndsWith(".pst")) } | Select-Object DisplayName, FilePath
				
				if ($ArchiveList -eq $null)
				{
					Format-Message -Level 'WARNING' -Message "No PST found -- end of script." | Out-File -FilePath $Logfile -Append
					Show-Msgbox "No PST file is open in Outlook, so there is no corrective action to apply. You can use Outlook normally." -Btn 0 -Icon 64
					return 0;
				}
				
				Format-Message -Level 'INFO' -Message "List of archives found :" | Out-File -FilePath $Logfile -Append
				Format-Message -Level 'INFO' -Message "$ArchiveList" | Out-File -FilePath $Logfile -Append
				
				$ArchiveList | foreach {
					$OldPSTPath = $_.FilePath
					$OldDisplayName = $_.DisplayName
					
					if ((Get-Item $OldPSTPath).length -gt $MinPSTSize)
					{
						
						
						$OriginalPSTFolder = $ns.Folders.Session.Stores | ?{ ($_.FilePath -eq $OldPSTPath) }
						$OriginalPST = $ns.GetFolderFromID($OriginalPSTFolder.StoreID)
						
						if ((Test-Path "$OldPSTPath_Rebuild.pst")) { remove-item -path "$OldPSTPath_Rebuild.pst" -force }
						
						# => un try catch ?
						# create new archive with the same display name
						try
						{
							$ns.AddStore($OldPSTPath + '_Rebuild.pst')
						}
						catch
						{
							
							Format-Message -Level 'ERROR' -Message "Error occured when trying to add store _Rebuild : $_" | Out-File -FilePath $Logfile -Append
						}
						
						$PST = $namespace.Folders.GetLast()
						$PST.Name = $OldDisplayName
						
						$i = 1
						
						#Create all subfolders (as source) and copy items
						$OriginalPST.Folders | foreach {
							$SubfolderName = $_.Name
							Write-Progress -Activity "Duplicating PST - $OldDisplayName" -status "Copy of subfolder: $SubfolderName" -percentComplete ($i / ($OriginalPST.Folders).count * 100)
							$i++
							
							$PST.Folders.Add($SubfolderName)
							#copy all items presents in subfolders
							foreach ($item in $OriginalPST.Folders.item($SubfolderName).items)
							{
								$item.copy()
								$item.Move($PST.Folders.Item($SubfolderName))
								if (-not $?)
								{
									$Errmsg = $Error[0].Exception.Message
									Format-Message -Level 'ERROR' -Message "Error occured moving : $Errmsg" | Out-File -FilePath $Logfile -Append
								}
								
							}
							
							
						}
						
						$ns.RemoveStore($PST)
						
					}
					else
					{
						Format-Message -Level 'INFO' -Message "This script doesn't correct PST file with size less than $MinPSTSize" | Out-File -FilePath $Logfile -Append
					}
				}
				
				Format-Message -Level 'INFO' -Message "PST duplication finished. Closing Outlook." | Out-File -FilePath $Logfile -Append
				
				#wait for all opp to complete
				Start-Sleep -s 20
				
				#Release object and close Outlook
				$ns.Logoff()
				$outlook.Quit()
				[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook)
				
				Get-Process OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force
				
				#Wait for Outlook to exit properly
				for ($i = 0; $i -le 12; $i++) # wait until outlook exit (2 minutes max.)
				{
					$GetProcessResult = Get-Process OUTLOOK -ErrorAction SilentlyContinue
					if ($GetProcessResult -eq $null) { break }
					Start-Sleep -s 10
					
				}
				
				Format-Message -Level 'INFO' -Message "Removing file suffix <PST>_Rebuild.pst" | Out-File -FilePath $Logfile -Append
				
				$CurrentDatebkp = get-date -f MM-dd-yyyy_HH_mm_ss
				
				#Rename files and all done
				$ArchiveList | foreach {
					
					if ((Get-Item $OldPSTPath).length -gt $MinPSTSize)
					{
						Rename-Item $_.FilePath ($_.FilePath + "_$CurrentDatebkp.backup")
						Rename-Item ($_.FilePath + '_Rebuild.pst') $_.FilePath
					}
					
				}
				
				Format-Message -Level 'INFO' -Message "End of script." | Out-File -FilePath $Logfile -Append
				
				Show-Msgbox "End of process. You can use Outlook normally." -Btn 0 -Icon 64
			}
			else
			{
				$statusbar1.Text = "Outlook don't exists on this system"
				Write-Log $statusbar1.Text
			}
			
			
		}
		
		if ($RadioInternetAccess.Checked)
		{
			$statusbar1.Text = "Trying to Correct Internet Access Issue."
			Write-Log $statusbar1.Text
			
			$ErrorActionPreference = "SilentlyContinue"
			$IEDeleteFlag = 0
			
			#Load DLL file in memory
			$global:ScriptPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
			$ExperimentalIOBinary = $global:ScriptPath + '\Microsoft.Experimental.IO.dll'
			[System.Reflection.Assembly]::LoadFile($ExperimentalIOBinary)

			$userid = $env:username
			#$subfolders = "C:\Users\$userid\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5", "C:\Users\$userid\AppData\Local\Microsoft\Windows\Temporary Internet Files\Low\Content.IE5"
             $subfolders = "C:\Users\amavaidy\test","C:\Users\amavaidy\test2"
			
			
            Foreach($P in $subfolders)
            {

                $files = [Microsoft.Experimental.IO.LongPathDirectory]::EnumerateFiles($p) 

                Foreach($file in $files)
                {

                    $delF=$file |? {$_ -like "*.bat"}

                    IF($delF)
                    {

                    [Microsoft.Experimental.IO.LongPathFile]::Delete($delF)
                    $IEDeleteFlag = $true
    
                    }
                    Else 
                    {
                    $IEDeleteFlag = $false
   
                    }
         
                    IF($IEDeleteFlag)
			        {
                        Write-Log ""
				        Write-Log "Files Deleted from $P"
			        }
			        else
			        {
				        Write-Log "File not Found on $p to Delete On System: $computername."	
                        Write-Log ""
			        }             

                }
            }

            
            
		}
		
		$statusbar1.Text = "Completed"
		$buttonResolve.Enabled = $true
	}
	
	$formWorkStationToolsV10_FormClosing = {
		Write-Log "Exiting the WorkStation Tool"
		Start-Sleep 1
	}
	
	$Outputrichtextbox1_TextChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonRepairOutlookPST_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonRepairOutlookProfile_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonCreateRegistryValue_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonNetworkLinkDisconnec_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonGPOIssue_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$radiobuttonDNSIssue_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$labelEnterComputerName_Click={
		#TODO: Place custom script here
		
	}
	
	$RadioInternetAccess_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	$RadioInternetAccess_CheckedChanged={
		#TODO: Place custom script here
		
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formWorkStationToolsV10.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$Outputrichtextbox1.remove_TextChanged($Outputrichtextbox1_TextChanged)
			$RadioInternetAccess.remove_CheckedChanged($RadioInternetAccess_CheckedChanged)
			$radiobuttonRepairOutlookPST.remove_CheckedChanged($radiobuttonRepairOutlookPST_CheckedChanged)
			$radiobuttonRepairOutlookProfile.remove_CheckedChanged($radiobuttonRepairOutlookProfile_CheckedChanged)
			$buttonResolve.remove_Click($buttonResolve_Click)
			$radiobuttonCreateRegistryValue.remove_CheckedChanged($radiobuttonCreateRegistryValue_CheckedChanged)
			$radiobuttonNetworkLinkDisconnec.remove_CheckedChanged($radiobuttonNetworkLinkDisconnec_CheckedChanged)
			$radiobuttonGPOIssue.remove_CheckedChanged($radiobuttonGPOIssue_CheckedChanged)
			$radiobuttonDNSIssue.remove_CheckedChanged($radiobuttonDNSIssue_CheckedChanged)
			$statusbar1.remove_PanelClick($statusbar1_PanelClick)
			$ConnectToComputer.remove_Click($ConnectToComputer_Click)
			$ComputerNameInputTextBox.remove_TextChanged($ComputerNameInputTextBox_TextChanged)
			$labelEnterComputerName.remove_Click($labelEnterComputerName_Click)
			$groupbox1.remove_Enter($groupbox1_Enter)
			$formWorkStationToolsV10.remove_Load($formWorkStationToolsV10_Load)
			$formWorkStationToolsV10.remove_Load($Form_StateCorrection_Load)
			$formWorkStationToolsV10.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$formWorkStationToolsV10.SuspendLayout()
	$groupbox3.SuspendLayout()
	$groupbox2.SuspendLayout()
	$groupbox1.SuspendLayout()
	$error_computer_name.BeginInit()
	#
	# formWorkStationToolsV10
	#
	$formWorkStationToolsV10.Controls.Add($groupbox3)
	$formWorkStationToolsV10.Controls.Add($groupbox2)
	$formWorkStationToolsV10.Controls.Add($statusbar1)
	$formWorkStationToolsV10.Controls.Add($groupbox1)
	$formWorkStationToolsV10.AutoScaleDimensions = '11, 28'
	$formWorkStationToolsV10.AutoScaleMode = 'Font'
	$formWorkStationToolsV10.ClientSize = '1125, 863'
	$formWorkStationToolsV10.Font = 'Segoe UI, 10pt'
	$formWorkStationToolsV10.Margin = '6, 7, 6, 7'
	$formWorkStationToolsV10.Name = 'formWorkStationToolsV10'
	$formWorkStationToolsV10.StartPosition = 'CenterScreen'
	$formWorkStationToolsV10.Text = 'WorkStation Tools v1.0'
	$formWorkStationToolsV10.add_Load($formWorkStationToolsV10_Load)
	#
	# groupbox3
	#
	$groupbox3.Controls.Add($Outputrichtextbox1)
	$groupbox3.Location = '50, 565'
	$groupbox3.Margin = '6, 6, 6, 6'
	$groupbox3.Name = 'groupbox3'
	$groupbox3.Padding = '6, 6, 6, 6'
	$groupbox3.Size = '1036, 255'
	$groupbox3.TabIndex = 3
	$groupbox3.TabStop = $False
	$groupbox3.Text = 'Output Display Box :'
	#
	# Outputrichtextbox1
	#
	$Outputrichtextbox1.Location = '30, 39'
	$Outputrichtextbox1.Margin = '6, 6, 6, 6'
	$Outputrichtextbox1.Name = 'Outputrichtextbox1'
	$Outputrichtextbox1.Size = '964, 204'
	$Outputrichtextbox1.TabIndex = 1
	$Outputrichtextbox1.Text = ''
	$Outputrichtextbox1.add_TextChanged($Outputrichtextbox1_TextChanged)
	#
	# groupbox2
	#
	$groupbox2.Controls.Add($RadioInternetAccess)
	$groupbox2.Controls.Add($radiobuttonRepairOutlookPST)
	$groupbox2.Controls.Add($radiobuttonRepairOutlookProfile)
	$groupbox2.Controls.Add($buttonResolve)
	$groupbox2.Controls.Add($radiobuttonCreateRegistryValue)
	$groupbox2.Controls.Add($radiobuttonNetworkLinkDisconnec)
	$groupbox2.Controls.Add($radiobuttonGPOIssue)
	$groupbox2.Controls.Add($radiobuttonDNSIssue)
	$groupbox2.Location = '50, 190'
	$groupbox2.Margin = '6, 6, 6, 6'
	$groupbox2.Name = 'groupbox2'
	$groupbox2.Padding = '6, 6, 6, 6'
	$groupbox2.Size = '1036, 363'
	$groupbox2.TabIndex = 2
	$groupbox2.TabStop = $False
	$groupbox2.Text = 'Step 2 : Select Operation'
	#
	# RadioInternetAccess
	#
	$RadioInternetAccess.Location = '39, 260'
	$RadioInternetAccess.Margin = '6, 6, 6, 6'
	$RadioInternetAccess.Name = 'RadioInternetAccess'
	$RadioInternetAccess.Size = '336, 35'
	$RadioInternetAccess.TabIndex = 7
	$RadioInternetAccess.TabStop = $True
	$RadioInternetAccess.Text = 'Correct Internet Access Issue'
	$RadioInternetAccess.UseVisualStyleBackColor = $True
	$RadioInternetAccess.add_CheckedChanged($RadioInternetAccess_CheckedChanged)
	#
	# radiobuttonRepairOutlookPST
	#
	$radiobuttonRepairOutlookPST.Location = '39, 225'
	$radiobuttonRepairOutlookPST.Margin = '6, 6, 6, 6'
	$radiobuttonRepairOutlookPST.Name = 'radiobuttonRepairOutlookPST'
	$radiobuttonRepairOutlookPST.Size = '373, 37'
	$radiobuttonRepairOutlookPST.TabIndex = 6
	$radiobuttonRepairOutlookPST.TabStop = $True
	$radiobuttonRepairOutlookPST.Text = 'Repair Outlook PST'
	$radiobuttonRepairOutlookPST.UseVisualStyleBackColor = $True
	$radiobuttonRepairOutlookPST.add_CheckedChanged($radiobuttonRepairOutlookPST_CheckedChanged)
	#
	# radiobuttonRepairOutlookProfile
	#
	$radiobuttonRepairOutlookProfile.Location = '39, 187'
	$radiobuttonRepairOutlookProfile.Margin = '6, 6, 6, 6'
	$radiobuttonRepairOutlookProfile.Name = 'radiobuttonRepairOutlookProfile'
	$radiobuttonRepairOutlookProfile.Size = '421, 39'
	$radiobuttonRepairOutlookProfile.TabIndex = 5
	$radiobuttonRepairOutlookProfile.TabStop = $True
	$radiobuttonRepairOutlookProfile.Text = 'Repair Outlook Profile'
	$radiobuttonRepairOutlookProfile.UseVisualStyleBackColor = $True
	$radiobuttonRepairOutlookProfile.add_CheckedChanged($radiobuttonRepairOutlookProfile_CheckedChanged)
	#
	# buttonResolve
	#
	$buttonResolve.Location = '398, 305'
	$buttonResolve.Margin = '6, 6, 6, 6'
	$buttonResolve.Name = 'buttonResolve'
	$buttonResolve.Size = '245, 46'
	$buttonResolve.TabIndex = 4
	$buttonResolve.Text = 'Resolve'
	$buttonResolve.UseVisualStyleBackColor = $True
	$buttonResolve.add_Click($buttonResolve_Click)
	#
	# radiobuttonCreateRegistryValue
	#
	$radiobuttonCreateRegistryValue.Location = '39, 119'
	$radiobuttonCreateRegistryValue.Margin = '6, 6, 6, 6'
	$radiobuttonCreateRegistryValue.Name = 'radiobuttonCreateRegistryValue'
	$radiobuttonCreateRegistryValue.Size = '436, 37'
	$radiobuttonCreateRegistryValue.TabIndex = 3
	$radiobuttonCreateRegistryValue.TabStop = $True
	$radiobuttonCreateRegistryValue.Text = 'StormShield Registry Value'
	$radiobuttonCreateRegistryValue.UseVisualStyleBackColor = $True
	$radiobuttonCreateRegistryValue.add_CheckedChanged($radiobuttonCreateRegistryValue_CheckedChanged)
	#
	# radiobuttonNetworkLinkDisconnec
	#
	$radiobuttonNetworkLinkDisconnec.Location = '39, 156'
	$radiobuttonNetworkLinkDisconnec.Margin = '6, 6, 6, 6'
	$radiobuttonNetworkLinkDisconnec.Name = 'radiobuttonNetworkLinkDisconnec'
	$radiobuttonNetworkLinkDisconnec.Size = '421, 34'
	$radiobuttonNetworkLinkDisconnec.TabIndex = 2
	$radiobuttonNetworkLinkDisconnec.TabStop = $True
	$radiobuttonNetworkLinkDisconnec.Text = 'Network Link Disconnected'
	$radiobuttonNetworkLinkDisconnec.UseVisualStyleBackColor = $True
	$radiobuttonNetworkLinkDisconnec.add_CheckedChanged($radiobuttonNetworkLinkDisconnec_CheckedChanged)
	#
	# radiobuttonGPOIssue
	#
	$radiobuttonGPOIssue.Location = '39, 88'
	$radiobuttonGPOIssue.Margin = '6, 6, 6, 6'
	$radiobuttonGPOIssue.Name = 'radiobuttonGPOIssue'
	$radiobuttonGPOIssue.Size = '490, 30'
	$radiobuttonGPOIssue.TabIndex = 1
	$radiobuttonGPOIssue.TabStop = $True
	$radiobuttonGPOIssue.Text = 'GPO Issue'
	$radiobuttonGPOIssue.UseVisualStyleBackColor = $True
	$radiobuttonGPOIssue.add_CheckedChanged($radiobuttonGPOIssue_CheckedChanged)
	#
	# radiobuttonDNSIssue
	#
	$radiobuttonDNSIssue.Location = '39, 49'
	$radiobuttonDNSIssue.Margin = '6, 6, 6, 6'
	$radiobuttonDNSIssue.Name = 'radiobuttonDNSIssue'
	$radiobuttonDNSIssue.Size = '421, 37'
	$radiobuttonDNSIssue.TabIndex = 0
	$radiobuttonDNSIssue.TabStop = $True
	$radiobuttonDNSIssue.Text = 'DNS Issue '
	$radiobuttonDNSIssue.UseVisualStyleBackColor = $True
	$radiobuttonDNSIssue.add_CheckedChanged($radiobuttonDNSIssue_CheckedChanged)
	#
	# statusbar1
	#
	$statusbar1.Location = '0, 832'
	$statusbar1.Margin = '6, 6, 6, 6'
	$statusbar1.Name = 'statusbar1'
	$statusbar1.Size = '1125, 31'
	$statusbar1.TabIndex = 1
	$statusbar1.Text = 'WorkStation Tools v1.0'
	$statusbar1.add_PanelClick($statusbar1_PanelClick)
	#
	# groupbox1
	#
	$groupbox1.Controls.Add($ConnectToComputer)
	$groupbox1.Controls.Add($ComputerNameInputTextBox)
	$groupbox1.Controls.Add($labelEnterComputerName)
	$groupbox1.Location = '50, 36'
	$groupbox1.Margin = '6, 7, 6, 7'
	$groupbox1.Name = 'groupbox1'
	$groupbox1.Padding = '6, 7, 6, 7'
	$groupbox1.Size = '1028, 141'
	$groupbox1.TabIndex = 0
	$groupbox1.TabStop = $False
	$groupbox1.Text = 'Step 1: Enter Computer Input'
	$groupbox1.add_Enter($groupbox1_Enter)
	#
	# ConnectToComputer
	#
	$ConnectToComputer.Location = '818, 48'
	$ConnectToComputer.Margin = '6, 6, 6, 6'
	$ConnectToComputer.Name = 'ConnectToComputer'
	$ConnectToComputer.Size = '176, 43'
	$ConnectToComputer.TabIndex = 2
	$ConnectToComputer.Text = 'Connect'
	$ConnectToComputer.UseVisualStyleBackColor = $True
	$ConnectToComputer.add_Click($ConnectToComputer_Click)
	#
	# ComputerNameInputTextBox
	#
	$ComputerNameInputTextBox.Location = '278, 52'
	$ComputerNameInputTextBox.Margin = '6, 6, 6, 6'
	$ComputerNameInputTextBox.Name = 'ComputerNameInputTextBox'
	$ComputerNameInputTextBox.Size = '488, 34'
	$ComputerNameInputTextBox.TabIndex = 1
	$ComputerNameInputTextBox.add_TextChanged($ComputerNameInputTextBox_TextChanged)
	#
	# labelEnterComputerName
	#
	$labelEnterComputerName.AutoSize = $True
	$labelEnterComputerName.Location = '39, 52'
	$labelEnterComputerName.Margin = '6, 0, 6, 0'
	$labelEnterComputerName.Name = 'labelEnterComputerName'
	$labelEnterComputerName.Size = '216, 28'
	$labelEnterComputerName.TabIndex = 0
	$labelEnterComputerName.Text = 'Enter Computer Name :'
	$labelEnterComputerName.add_Click($labelEnterComputerName_Click)
	#
	# error_computer_name
	#
	$error_computer_name.ContainerControl = $formWorkStationToolsV10
	$error_computer_name.EndInit()
	$groupbox1.ResumeLayout()
	$groupbox2.ResumeLayout()
	$groupbox3.ResumeLayout()
	$formWorkStationToolsV10.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formWorkStationToolsV10.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formWorkStationToolsV10.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formWorkStationToolsV10.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formWorkStationToolsV10.ShowDialog()

} #End Function

#Call the form
Show-WorkStation_Tools_psf | Out-Null
