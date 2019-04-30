<#Getting the Forest Functional level 
[system.directoryservices.activedirectory.forest]::GetCurrentForest().ForestMode
#Getting the Domain Functional level  
[system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainMode
<#DCs Inventory 
[system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers | `
Select Name,IPAddress,OSVersion,Roles,SiteName,Partitions,IsReadOnly
#>
#Finding All DCs in Forest
$allDCs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }
#Declare Hash table
$Inv = [ordered]@{} 

foreach ($dc in $allDCs) {
#Data Collection in various Arrays
#$ErrorActionPreference = "silentlycontinue"
    Try{
    $Continue= $true
    $bios = Get-WmiObject -Class win32_bios -ComputerName $($dc.name) -ErrorAction 'Stop'
    
    }
    Catch
    {
    $Continue =$false 
    
    }
    if ($Continue)
    {
        $OS = Get-WmiObject -Class win32_OperatingSystem -ComputerName $dc
        $ComputerSystem = Get-WmiObject -Class win32_ComputerSystem -ComputerName $($dc.name)
        $Pagefilesize = get-wmiobject Win32_pagefileusage -ComputerName $($dc.name) | % {$_.AllocatedBaseSize} #| Select @{n='PagefileSize' ;e={"{0:n2}" -f ($_.AllocatedBaseSize/1gb)}}
        $DNS =  Get-Service -Name DNS -ComputerName $($dc.name) | Select Status
        $processor = Get-WmiObject -Class win32_Processor -ComputerName $($dc.name) 
        $volume = Get-WMIObject Win32_LogicalDisk -ComputerName $($dc.name)`
            | select __SERVER, DriveType, VolumeName, Name, @{n='Size' ;e={"{0:n2}" -f ($_.size/1gb)}},@{n='FreeSpace';e={"{0:n2}" -f ($_.freespace/1gb)}}, @{n='PercentFree';e={"{0:n2}" -f ($_.freespace/$_.size*100)}} `
            | Where-Object {$_.DriveType -eq 3}
        $NIC = Get-WmiObject Win32_NetworkAdapterConfiguration -Namespace "root\CIMV2" -ComputerName $($dc.name) | where{$_.IPEnabled -eq "True"} 


        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $($dc.name)) 
        $RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\services\\NTDS\\Parameters")
        $RegKey1= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\services\\Netlogon\\Parameters")   
        $NTDSPath = $Regkey.GetValue("DSA Database file") 
        $NTDSREMOTEPath =  "\\$($dc.name)\$NTDSPath" -replace ":","$" 
        $NTDSREMOTEPath = Get-item $NTDSREMOTEPath | Select-Object -ExpandProperty Length

            $inv.DomainController = $dc.HostName
            $inv.Model = $ComputerSystem.Model
            $Inv.OperatingSystem = $dc.OperatingSystem
            $inv.ServicePack = $dc.OperatingSystemServicePack
            $inv.IPV4 = $dc.IPv4Address
            $inv.OSArchitecture = $OS.OSArchitecture
            $inv.Subnet = $nic.IPSubnet[0]
            $inv.MACAddress = $nic.MACAddress
            $inv.ADSite = $dc.Site
            $inv.DNS = $DNS.Status
            $inv.FSMO = if($($dc.OperationMasterRoles)){$(@($dc.OperationMasterRoles) -join "`r`n")}
            $inv.GlobalCatalog   = $dc.isGlobalCatalog
            $inv.RODC = $dc.IsReadOnly
            $inv.Partitions = (@($dc.Partitions) -join "`r`n")
            $inv.ProcessorAdddressWidth = (@($processor.AddressWidth | Select -Unique) -join "`r`n")
            $inv.ProcessorClockMHz = (@($processor.MaxClockSpeed | Select -Unique) -join "`r`n")
            $inv.ProcessorCores = $processor.NumberOfCores.count 
            $inv.ProcessorLogical = $processor.NumberOfLogicalProcessors.count
            $inv.ProcessorMake = (@($processor.Manufacturer | Select -Unique) -join "`r`n")
            $inv.MemoryCapacity = "$([string]([System.Math]::Round($ComputerSystem.TotalPhysicalMemory/1gb,2))) GB"
            $inv.PagefileSizeGB = ($Pagefilesize/1KB).ToString("0.000"+" GB")
            $inv.VolumeLetter = (@($volume.Name) -join "`r`n")
            $inv.VolmeFreeSpaceGB = (@($volume.FreeSpace) -Join "`r `n")
            $inv.VolumeCapacityGB = (@($volume.Size) -join "`r`n")
            $inv.SysVolPath = $Regkey1.GetValue("SysVol")
            $inv.DataBasePath = $Regkey.GetValue("DSA Database file") 
            $inv.NTDSSize = ($NTDSREMOTEPath /1GB).ToString("0.000"+" GB")
            $inv.LOGFilePath = $Regkey.GetValue("Database log files path")


    $object = New-Object PSObject -property $inv
    $object | epcsv -Path c:\temp_new\dcinventory.csv -Append -NoTypeInformation -Delimiter ";"
    #$object
    }
}