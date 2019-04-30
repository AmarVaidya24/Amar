#$File_Path = C:\TEST\Inventory.csv
$ScriptPath= "C:\TEST"

Function PIMDevice
{
			#$statusbar1.Text = "Processing PIM LIC Device File.."
			$Global = Import-Csv -Path C:\TEST\Inventory.csv | Sort-Object 'safe', 'Target system address' –Unique #This is to remove duplicate
			
			#Filtering the User account.
			$Filtre = $Global | ? { ($_.'Platform ID' -ne "Wks-Win-Local2") -and ($_.'Target system address' -notlike "1.1*") -and ($_.'Target system address' -notlike "MAIN") -and ($_.safe -like "*EP*" -or $_.safe -like "*GP*" -or $_.safe -like "*HD*" -or $_.safe -like "*RC*" -or $_.safe -like "*MS*") }
			
			
			
			#Array To Store Value.
			$ArrList = [System.Collections.ArrayList]@()
			
			
			$Path_CSV = "$ScriptPath\B00889_-_R-PSSI_PIM_Device_-_detailled_inventory.txt"
			
			#Add title in File.
			
			#Count of Users For Column N
			$Number = 1
			
			#Array To Store Value.
			#$ADObjects = @()
			
			$ArrList = [System.Collections.ArrayList]@()
			
			#Excel Format Save Option.
			Add-Type -AssemblyName Microsoft.Office.Interop.Excel
			$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault
			
			#Aditional Value to Import data in EXcel.
			
			$xlWindows = 2
			$xlDelimited = 1 # 1 = delimited, 2 = fixed width
			$xlTextQualifierDoubleQuote = 1 # 1= doublt quote, -4142 = no delim, 2 = single quote
			$consequitiveDelim = $False;
			$tabDelim = $False;
			$semicolonDelim = $False;
			$commaDelim = $True;
			$StartRow = 1
			$Semicolon = $True
			
			
			foreach ($IGS in $Filtre)
			{
				
				$safe = $IGS.Safe
				
				
				#Column B
				#
				
				switch -Regex ($Safe)
				{
					"\W+MS*" { $SafeCode = "20BF001"; Break }
					"\W+RC*" { $SafeCode = "20BF020"; Break }
					"\W+EP*" { $SafeCode = "20BF029"; Break }
					"\W+GP*" { $SafeCode = "20BF045"; Break }
					default { $SafeCode = "" }
				}
				
				#Column D 
				#Column D : 3,6,9 or 11 but only one value must set 
				
				#$BillingQuater = $listbox.selectedItem
				
				$BillingQuater = "March (Q1)"
				
				switch ($BillingQuater)
				{
					"March (Q1)" { $BillingPeriod = "3" }
					"June (Q2)" { $BillingPeriod = "6" }
					"September (Q3)" { $BillingPeriod = "9" }
					"November (Q4)" { $BillingPeriod = "11" }
					default { $BillingPeriod = " " }
				}
				
				#Column E 
				#Column E Value is Fix 
				
				
				#Column F 
				
				switch -Regex ($Safe)
				{
					"\W+MS*" { $ClientCode = "MS"; Break }
					"\W+RC*" { $ClientCode = "RC"; Break }
					"\W+EP*" { $ClientCode = "EP"; Break }
					"\W+GRP*" { $ClientCode = "GP"; Break }
					"\W+HD*" { $ClientCode = "HD"; Break }
					"\W+RC*" { $ClientCode = "RC"; Break }
					"\W+TGS*" { $ClientCode = "EP"; Break }
					default { $ClientCode = "" }
				}
				
				
				#column I
				#column I is the month of script execution
				
				$MonthofScriptExecution = (Get-Date).Month
				
				#column J
				#column J is the value of  'Target system address' exported from csv file 
				
				$TargetSystemAddress = $IGS.'Target system address'
				
				#Column N
				#column N is the line number
				
				
				$ADObjects = New-Object psobject
				$ADObjects | Add-Member –membertype NoteProperty –name "Type Activité(TA)" –value "B00889"
				$ADObjects | Add-Member –membertype NoteProperty –name "Code Identifiant de Facturation" –value "$SafeCode"
				$ADObjects | Add-Member –membertype NoteProperty –name "Nb UO ou Montant" –value "1"
				$ADObjects | Add-Member –membertype NoteProperty –name "Mois Traitement" –value "$BillingPeriod"
				$ADObjects | Add-Member –membertype NoteProperty –name "Libellé TA" –value "R-PSSI PIM Device"
				$ADObjects | Add-Member –membertype NoteProperty –name "Client" –value "$ClientCode"
				$ADObjects | Add-Member –membertype NoteProperty –name "Entité" –value " "
				$ADObjects | Add-Member –membertype NoteProperty –name "Pays" –value " "
				$ADObjects | Add-Member –membertype NoteProperty –name "Période facturée" –value "$MonthofScriptExecution"
				$ADObjects | Add-Member –membertype NoteProperty –name "Identifiant" –value "$TargetSystemAddress"
				$ADObjects | Add-Member –membertype NoteProperty –name "Code d'identifiant" –value " "
				$ADObjects | Add-Member –membertype NoteProperty –name "Donnée libre 1" –value " "
				$ADObjects | Add-Member –membertype NoteProperty –name "Donnée libre 2" –value "$safe"
				$ADObjects | Add-Member –membertype NoteProperty –name "N°de la ligne du fichier" –value "$Number"
				
				
				$ArrList += $ADObjects
				
				
				$Number = $Number + 1
				
				
				
			}
			
			
			$ArrList | Export-Csv -path $Path_CSV -NoTypeInformation #This is to remove duplicate
			
			
			$Excel = New-Object -ComObject excel.application
			#$workbook = $Excel.workbooks.add() 
			$Excel.visible = $true
			
			
			$workbook = $excel.workbooks.OpenText($Path_CSV, $xlWindows, $StartRow, $xlDelimited, $xlTextQualifierDoubleQuote, $consequitiveDelim, $tabDelim, $semicolonDelim, $commaDelim)
			$sheet = $excel.ActiveWorkbook.Sheets.Item(1)
			
			$table = $sheet.ListObjects.add(1, $sheet.UsedRange, 0, 1)
			$sheet.UsedRange.EntireColumn.AutoFit()
			
			Remove-Item "$ScriptPath\B00889_-_R-PSSI_PIM_Device_-_detailled_inventory.xlsx" -Force -ErrorAction SilentlyContinue
			
			$Excel.ActiveWorkbook.saveas("$ScriptPath\B00889_-_R-PSSI_PIM_Device_-_detailled_inventory.xlsx", $xlFixedFormat)
			$Excel.ActiveWorkbook.close($true)
			$excel.quit()
			
			Remove-Item "$ScriptPath\B00889_-_R-PSSI_PIM_Device_-_detailled_inventory.txt" -Force -ErrorAction SilentlyContinue
			
			#$statusbar1.Text = "Output path $ScriptPath\B00889_-_R-PSSI_PIM_Device_-_detailled_inventory.xlsx"
			

		}

PIMDevice 