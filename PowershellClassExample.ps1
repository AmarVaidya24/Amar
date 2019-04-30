Class Serverdetails
{


[string] OSDetails ([string]$computer)
{

$s=Get-WmiObject Win32_operatingsystem -ComputerName $computer|select -ExpandProperty caption

return $s

}


[datetime] Uptime ([String]$computer)
{
$s=Get-WmiObject Win32_operatingsystem -ComputerName $computer|select @{n='UPtime';E={$_.convertToDatetime($_.lastbootuptime)}}

return $s.uptime
}


[String] Tostring()
{

Return $this.computerName + ":"+$this.OS

}


}


$server=[serverdetails]::new()



$server.OSDetails("localhost")

$server.uptime("localhost")



