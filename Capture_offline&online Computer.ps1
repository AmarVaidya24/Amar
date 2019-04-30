$compters=Get-Content C:\temp\serverlist.txt

$Array=@()
foreach($comp in $compters)
{




$A = Get-WmiObject -Class Win32_operatingsystem -ComputerName $comp | select SystemDirectory,Organization,BuildNumber,RegisteredUser,SerialNumber,Version,@{Name="Computername"; Expression = {$comp}} 

if($? -eq $false)
{

$A = "$comp Failed"

}



$Array += $A


}

$Array