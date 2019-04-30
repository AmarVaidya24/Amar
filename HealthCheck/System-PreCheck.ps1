

function routeprint {
$routeprinttemp = route print
$routeprinttemp | out-file "C:\OSTC\precheck\routeprint.txt"
}




function Get-IPconfig {
$Ipconfig = Ipconfig /all
$Ipconfig | out-file "C:\OSTC\precheck\Ipconfig_Pre.txt"
}




function AVInfo ($servername) {

    $main = "Localmachine" 
    $Path = "SOFTWARE\Symantec\Symantec Endpoint Protection\CurrentVersion\public-opstate" 
    $key = "DeployRunningVersion"
    $key1 = "LatestVirusDefsDate"


    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($main, $servername) 
    $regKey= $reg.OpenSubKey($Path) 
    $Version = $regkey.GetValue($key)

    $defDate= $regkey.GetValue($key1)

    $avinfoObject = New-Object psobject
    $avinfoObject | Add-Member NoteProperty "Version" $Version
    $avinfoObject | Add-Member NoteProperty "Update" $defDate

    return $avinfoObject
}

Function IPdetails($servername)
{

    $IPAddress = (Get-WmiObject -ComputerName $servername Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).IPAddress
    $DNSDomain = (Get-WmiObject -ComputerName $servername Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).DNSDomain
    $IPSubnet = (Get-WmiObject -ComputerName $servername Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).IPSubnet
    $DefaultIPGateway = (Get-WmiObject -ComputerName $servername Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }).DefaultIPGateway

    $IPObj = New-Object psobject
    $IPObj | Add-Member NoteProperty "IPAddress" $IPAddress
    $IPObj | Add-Member NoteProperty "DNSDomain" $DNSDomain
    $IPObj | Add-Member NoteProperty "IPSubnet" $IPSubnet
    $IPObj | Add-Member NoteProperty "DefaultIPGateway" $DefaultIPGateway


   
    return $IPObj

}

function filesharesinfo ($servername) {
$filesharesinfotemp = get-wmiobject Win32_Share -computername $servername
$filesharespermissions = $filesharesinfotemp | Select-Object name

$filesharesinfoobjects = @()
for ($i=0 ; $i -lt ($filesharesinfotemp ).count ; $i++)
{
$filesharesinfoobject = "" | Select-Object Name,Path,Description
$filesharesinfoobject.Name = $filesharesinfotemp[$i].Name
$filesharesinfoobject.Path = $filesharesinfotemp[$i].Path
$filesharesinfoobject.Description = $filesharesinfotemp[$i].Description
$filesharesinfoobjects += $filesharesinfoobject
}
return $filesharesinfoobjects
}




function Server-Precheck{
<#
.CREATED BY:
    Vaidya Amar
.CREATED ON:
    11\3\2013
.SYNOPSIS
    Creates an HTML file on the Desktop of the local machine full of detailed system information.
.DESCRIPTION
    Server-Precheck utilizes WMI to retrieve information related to the physical hardware of the machine(s), the available `
    disk space, when the machine(s) last restarted and bundles all that information up into a colored HTML report.
.EXAMPLE
   Server-Precheck -Computername localhost, SRV-2012R2, DC-01, DC-02
   This will create an HTML file on your desktop with information gathered from as many computers as you can access remotely
#>
      [CmdletBinding(SupportsShouldProcess=$True)]
param([Parameter(Mandatory=$false,
      ValueFromPipeline=$true)]
      #[string]$FilePath = "C:\users\$env:USERNAME\desktop\Write-HTML.html",
      [string]$FilePath = "C:\ostc\precheck\PreCheck.html",
      [string[]]$Computername = $env:COMPUTERNAME,

$Css='<style>table{margin:auto; width:98%}
              Body{background-color:LightSeaGreen; Text-align:Center;}
                th{background-color:DarkOrange; color:white;}
                td{background-color:Lavender; color:Black; Text-align:Center;}
     </style>' )

Begin{ Write-Verbose "HTML report will be saved $FilePath" 

if(!(Test-Path "C:\ostc\"))
{
md C:\ostc\Precheck
md C:\ostc\Postcheck
#Write-Host "Path not exist"

}
Else {
#Write-Host "path exist"
}

}

Process{ 

$Hardware = Get-WmiObject -class Win32_ComputerSystem -ComputerName $Computername | 
         Select-Object Name,Domain,Manufacturer,Model,NumberOfLogicalProcessors,
         @{ Name = "Installed Memory (GB)" ; Expression = { "{0:N0}" -f( $_.TotalPhysicalMemory / 1gb ) } } |
         ConvertTo-Html -Fragment -As Table -PreContent "<h2>Hardware</h2>" | 
         Out-String

$Hardware1=Get-WmiObject -class Win32_ComputerSystem -ComputerName $Computername | 
         Select-Object Name,Domain,Manufacturer,Model,NumberOfLogicalProcessors,
         @{ Name = "Installed Memory (GB)" ; Expression = { "{0:N0}" -f( $_.TotalPhysicalMemory / 1gb ) } }

$Hardware1 | epcsv C:\ostc\Precheck\Hardware_Pre.Csv -NoTypeInformation -Append



$PercentFree = Get-WmiObject Win32_LogicalDisk -ComputerName $Computername | 
               Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,VolumeName,DeviceID,
               @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f( $_.Size / 1gb) } },
               @{ Name = "Free Space (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } },
               @{ Name = "Percent Free" ; Expression = { "{0:P0}" -f( $_.FreeSpace / $_.Size ) } } |
               ConvertTo-Html -Fragment -As Table -PreContent "<h2>Available Disk Space</h2>" | 
               Out-String

$PercentFree1 = Get-WmiObject Win32_LogicalDisk -ComputerName $Computername | 
               Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,VolumeName,DeviceID,
               @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f( $_.Size / 1gb) } },
               @{ Name = "Free Space (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } },
               @{ Name = "Percent Free" ; Expression = { "{0:P0}" -f( $_.FreeSpace / $_.Size ) } }


$PercentFree1 |Export-Csv C:\OSTC\precheck\Disk_Pre.csv -NoTypeInformation -Append


$Voulmeinfo =Get-Volume |select OperationalStatus,HealthStatus,FileSystemType,AllocationUnitSize,DriveLetter,FileSystemLabel,Size|ConvertTo-Html -Fragment -as Table -PreContent "<H2>Volume information</h2> "|Out-String


$Patches = Get-WmiObject Win32_QuickFixEngineering -computername $Computername | Where-object  { $_.InstalledOn -gt (get-date).AddDays(-20) }|
            Select-Object HotFixID,Description,InstalledBy,InstalledOn |
            ConvertTo-Html -Fragment -As Table -PreContent "<h2>Patch Details</h2>" | 
            Out-String



$auto_Services = Get-WmiObject win32_service -ComputerName $Computername | Where-Object { $_.State -eq "Running" } | 
                  select-object SystemName,Name,DisplayName,Processid,Startmode,state|
                  ConvertTo-Html -Fragment -As Table -PreContent "<h2>Runing Services</h2>" |
                  Out-String
                  
$auto_Services1 = Get-WmiObject win32_service -ComputerName $Computername | Where-Object { $_.State -eq "Running" } | 
                  select-object SystemName,Name,DisplayName,Processid,Startmode,state

$auto_Services1 |epcsv C:\OSTC\precheck\Services_Pre.csv -NoTypeInformation -Append

    
$Restarted = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computername | Select-Object CSName,Caption,
             @{ Name = "Last Restarted On" ; Expression = { $_.Converttodatetime( $_.LastBootUpTime ) } } |
             ConvertTo-Html -Fragment -As Table -PreContent "<h2>Last Boot Up Time</h2>" | 
             Out-String

#$Stopped = Get-WmiObject -Class Win32_Service -ComputerName $Computername | 
   #        Where-Object { ($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped") } |
   #        Select-Object SystemName, DisplayName, Name, StartMode, State, Description |
   #        ConvertTo-Html -Fragment -As Table -PreContent "<h2>Services currently stopped that are set to autostart</h2>" | 
   #        Out-String
$osc = Get-WmiObject win32_service -ComputerName $Computername |?{$_.name -eq "bits"} |select Name,DisplayName,StartMode,State|
       ConvertTo-Html -Fragment -as Table -PreContent "<h2>OSC Service Status</h2>"|
       Out-String

$osc1 = Get-WmiObject win32_service -ComputerName $Computername |?{$_.name -eq "bits"} |select Name,DisplayName,StartMode,State

$osc1| epcsv C:\ostc\Precheck\OSC.csv
    

$ipdata= IPdetails $Computername |select @{n="IPAddress";e={[string]$_.IPAddress}},@{n="DNSDomain";e={[string]$_.DNSDomain}},@{n="IPSubnet";e={[string]$_.IPSubnet}},@{n="DefaultIPGateway";e={[string]$_.DefaultIPGateway}}|
         ConvertTo-Html -Fragment -As Table -PreContent "<h2>Server IP Details</h2>" | 
         Out-String

$ipdata1= IPdetails $Computername |select @{n="IPAddress";e={[string]$_.IPAddress}},@{n="DNSDomain";e={[string]$_.DNSDomain}},@{n="IPSubnet";e={[string]$_.IPSubnet}},@{n="DefaultIPGateway";e={[string]$_.DefaultIPGateway}}

$ipdata1|epcsv C:\OSTC\precheck\IpDetails_Pre.csv -NoTypeInformation -Append



$avData=AVInfo $Computername| select Version,@{Name = "AV Update Date" ; Expression = { $_.Update} } |
        ConvertTo-Html -Fragment -As Table -PreContent "<h2>Anti-Virus Version & Update Date</h2>" |
        Out-String

$avData1=AVInfo $Computername| select Version,@{Name = "AV Update Date" ; Expression = { $_.Update} }

$avData1 |epcsv C:\OSTC\precheck\AVDetails_Pre.csv -NoTypeInformation -Append


$fileShare= filesharesinfo $Computername|select Name,Path,Description|
            ConvertTo-Html -Fragment -As Table -PreContent "<h2>File Share Details</h2>" |
            Out-String



$Report = ConvertTo-Html -Title "$Computername" `
                         -Head "<h1>PowerShell Reporting<br><br>$Computername</h1><br>This report was ran: $(Get-Date)" `
                         -Body "$Hardware $PercentFree $Restarted $Patches $avData $ipdata $Voulmeinfo $fileShare $osc $auto_Services $Css" 
                       
                         
}

End{ $Report | Out-File $Filepath ; Invoke-Expression $FilePath }

}
Server-Precheck
Write-Host "Route Print details are not available for remote computer."
routeprint
Get-IPconfig

