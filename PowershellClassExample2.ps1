Class Serverdetails
{
[String]$Computename
[String]$OSName
[String]$ServerUptime

Serverdetails () 
{
$this.Computename =$Env:COMPUTERNAME

    $caption=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select -ExpandProperty caption -ErrorAction Stop
    $this.OSName = $caption

    $Uptime=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select @{n='UPtime';E={$_.convertToDatetime($_.lastbootuptime)}}
    $this.ServerUptime =$Uptime.uptime
  



}

Serverdetails([String]$Computer)
{

    $this.Computename =$Computer

    $caption=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select -ExpandProperty caption -ErrorAction Stop
    $this.OSName = $caption

    $Uptime=Get-WmiObject Win32_operatingsystem -ComputerName $($this.Computename)|select @{n='UPtime';E={$_.convertToDatetime($_.lastbootuptime)}}
    $this.ServerUptime =$Uptime.uptime
  
}



}


$server=[serverdetails]::new("localhost")

$server

$newServer= new-object serverdetails -ArgumentList "localhost"

$newServer

$brandnewserver =[serverdetails]::new()
$brandnewserver