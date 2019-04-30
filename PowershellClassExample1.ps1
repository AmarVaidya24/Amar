Class Serverdetails
{
[String]$Computename

Serverdetails([String]$Computer)
{

$this.Computename =$Computer
}


[string] OSDetails ()
{

$s=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select -ExpandProperty caption

return $s

}


[datetime] Uptime ()
{
$s=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select @{n='UPtime';E={$_.convertToDatetime($_.lastbootuptime)}}

return $s.uptime
}


[String] Tostring()
{

Return $this.computerName + ":"+$this.OS

}


}


$server=[serverdetails]::new("localhost")

$server.OSDetails()

$server.uptime()



