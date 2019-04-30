$logfile = "Servers_Service_Status_$(Get-Date -format "dd-MMM-yyyy-HH-mm").log"
$ErrorActionPreference = "SilentlyContinue"
$servers = Get-Content "C:\temp\serverlist.txt"
$ServiceName= 'bits'



function log($string, $color)
{
	
	if ($color -eq $null) { $color = "white" }
	
	Write-Host $(Get-Date -format "dd-MMM-yyyy-HH-mm") $string -foregroundcolor $color
	
	$date = $(Get-Date -format "dd-MMM-yyyy HH:mm:ss")
	
	$string = $date + " " + $string
	
	$string | out-file -Filepath "C:\Temp\$logfile" -append
	
}



$alive = $true
do {
	$alive = $true
	foreach ($server in $servers) {
	
		$wmi = Get-WmiObject -Class "Win32_OperatingSystem" -ComputerName $server
			
		if ($wmi -ne $null) 
        {
			"$server Uptime:" + $wmi.ConvertToDateTime($wmi.LastBootUpTime).tostring("dd/MM/yyyy HH:mm:ss")

            $A = Get-Service -ComputerName $Server -Name $ServiceName
             
            if ($A.Status -eq "Stopped") 
            {
            $A.start()
            Log "Service is started on $Server" Green
            } 
            elseIf ($A.status -eq "Running") 
            {
            log "$Server : $($A.Name):$($A.Status)" Yellow
            }
            $alive = $true
		} 
        else 
        {
			Log "$server : Offline" Red
			$alive = $false
		}
	}
} while ($alive -eq $false)








