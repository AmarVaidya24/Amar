Start-Transcript


$Class=@" 

Class Car 
{

}
"@

Add-Type -TypeDefinition  -OutputType ConsoleApplication

#clear a log
wevtutil cl "Microsoft-Windows-Powershell/Operational"

powershell -noprofile {Invoke-Expression 'get-process -name Power*'} |sort -Descending ID

cmd /c echo -noprofile {Invoke-Expression 'get-process -name Power*'}

powershell -noprofile -encodedcommand SQBuAHYAbwBrAGUALQBFAHgAcAByAGUAcwBzAGkAbwBuACAAJwBnAGUAdAAtAHAAcgBvAGMAZQBzAHMAIAAtAG4AYQBtAGUAIABQAG8AdwBlAHIAKgAnAA==



[console]::("Write"+"Line")("Hello World")

[console]::Writeline("Hello")


[System.Console] 

Get-Command -Noun Cmsmessage

New-SelfSignedCertificate -Subject 'amar@Vaidya' -Type DocumentEncryptionCertLegacyCsp

#CHange Error color
$psISE.Options.ErrorForegroundColor =[System.Windows.Media.Colors]::Chartreuse

Function Show-Error
{


Get-Item C:\doesnotexist.txt

}
Show-Error

 $Error `
    |Group-Object `
    |Sort-Object -Property count -Descending `
    |Format-Table -Property count,Name -AutoSize
    
 $Error[0] |fl * -Force
 $Error[0].Exception
 $Error[0].Exception |fl * -Force
 $Error[0].Exception.InnerException |fl * -Force

 $Error[0].ScriptStackTrace
 $Error[0].Exception.StackTrace

#List of the Powershell Cource 
aka.ms/mvapsvideo

 #clean up behind yourself 
 $Error.Remove($Error[0])
 $Error.RemoveAt(0)
 $Error.RemoveRange(0,10)
 $Error.Clear() #clear the $error Collection

































