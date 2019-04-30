 #function B00887_-_R-PSSI_PIM_Lic_Admin ($File_Path, $Folder_Path,$Month,$month_int)
 #{

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault

$Excel = New-Object -ComObject excel.application 
#$workbook = $Excel.workbooks.add() 

$Excel.visible = $true 
$wb = $excel.Workbooks.Add()

$wb.WorkSheets.Add()

$sheet = $wb.Worksheets.Item(1)

$services =Get-Service

$row=1

$sheet.Cells.Item($row, 1)="Name"
$sheet.Cells.Item($row, 2)="Status"
$sheet.Cells.Item($row, 3)="DisplayName"

$row=2

for($i=0;$i -le ($services.Count-1);$i++)
{

$sheet.Cells.Item($i+$row, 1)=$services.name[$i]
$sheet.Cells.Item($i+$row, 2)=[string]$services.Status[0]
$sheet.Cells.Item($i+$row, 3)=$services.DisplayName[$i]

}

$table=$sheet.ListObjects.add( 1,$sheet.UsedRange,0,1)
$sheet.UsedRange.EntireColumn.AutoFit()


$Excel.ActiveWorkbook.saveas("C:\test\Service.xlsx",$xlFixedFormat)
$Excel.ActiveWorkbook.close($true)
$excel.quit() 

 

