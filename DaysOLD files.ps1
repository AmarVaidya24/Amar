Function GetOldFile
{
$Days = "2" #You can change the number of days here
$TargetFolder = "E:\tesrt\logs" #Enter full Target folder path

if (Test-Path $TargetFolder)
{
$Now = Get-Date
$LastWrite = $Now.AddDays(-$days)
$Files = get-childitem $TargetFolder -include *.log -recurse |Where {$_.LastWriteTime -le "$LastWrite"} #Change the file type to different one if needed (*.log)

foreach ($File in $Files)
{

write-host "Deleting file $File" -foregroundcolor "Red"; Copy-Item -Destination $File | out-null}

}
Else
{

Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -foregroundcolor "red"}

}
GetOldFile

