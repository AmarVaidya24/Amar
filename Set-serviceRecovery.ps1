function Set-Recovery{
    param
    (
        [string] [Parameter(Mandatory=$true)] $ServiceDisplayName,
        [string[]] [Parameter(Mandatory=$true)] $Servers,
        [string] $action1 = "restart",
        [int] $time1 =  30000, # in miliseconds
        [string] $action2 = "restart",
        [int] $time2 =  30000, # in miliseconds
        [string] $actionLast = "restart",
        [int] $timeLast = 30000, # in miliseconds
        [int] $resetCounter = 4000 # in seconds
    )
    
    
    $action = $action1+"/"+$time1+"/"+$action2+"/"+$time2+"/"+$actionLast+"/"+$timeLast

     foreach($SingleServer In $Servers)
     {
        $serverPath = "\\" + $SingleServer
        $services = Get-CimInstance -ClassName 'Win32_Service' -ComputerName $SingleServer | Where-Object {$_.DisplayName -imatch $ServiceDisplayName}

        foreach ($service in $services)
        {
        
            $output = sc.exe $serverPath failure $($service.Name) actions= $action reset= $resetCounter
        }
    
     }
}
 #Keep in mind this script doesn't use Service Name but Display Name.
Set-Recovery -ServiceDisplayName "Pulseway" -Server "locahost"