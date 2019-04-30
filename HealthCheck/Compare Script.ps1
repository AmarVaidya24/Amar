 $Global:hardware
 $Global:Services
 $Global:DISK
 $Global:Av

 
 Function Hardware-Compare
 {
 
 $OldCSV = Import-Csv -Path C:\ostc\Precheck\Hardware_Pre.Csv
 $NewCSV = Import-Csv -Path C:\ostc\Postcheck\Hardware_Post.Csv

 $output = @()

 forEach ($Column in $OldCsv) 
 {      
     $result = $NewCSV | Where-Object {$Column.Name -eq $_.Name} 
           
     $CpuNumberofCore = if ($Column.'Installed Memory (GB)' -ne $result.'Installed Memory (GB)') {"Previous: " + $Column.'Installed Memory (GB)' + " | Now:" + $result.'Installed Memory (GB)'} else{"No Change"}
       

      
      $output += New-object PSObject -property @{  
       Name = $Column.Name
       Domain = $Column.Domain
       InstalledMemory=  $CpuNumberofCore
       
     }  
   }  


 $output | select-object Name,Domain,InstalledMemory | Export-Csv -Path C:\OSTC\Postcheck\Hardware_Changes.csv -NoTypeInformation 
 $Global:hardware = $output | select-object Name,Domain,InstalledMemory |ConvertTo-Html -Fragment -As Table -PreContent "<h2>Hardware Compare</h2> "|Out-String
 Return $Global:hardware
}


 Function Service-Compare
 {
 
 
 $OldCSV = Import-Csv -Path C:\OSTC\precheck\Services_pre.csv
 $NewCSV = Import-Csv -Path C:\ostc\Postcheck\services_Post.csv
 $output = @()
 forEach ($Column in $OldCsv) 
 {      
     $result = $NewCSV | Where-Object {$Column.Name -eq $_.Name} 
           
     #$Service = if ($Column.State -ne $result.State) {"Found Change"}  

     $Servicestate = if ($Column.State -ne $result.State) {"Previous: " + $Column.State + " | Now:" + $result.State} else{"No Change"}
      
      $output += New-object PSObject -property @{
       SystemName= $Column.SystemName       
       ServiceName = $Column.Name
       Servicestate = $Servicestate 
       
     }  
   }  
 $output | select-object SystemName, ServiceName, Servicestate | Export-Csv -Path C:\OSTC\PostCheck\Service_Changes.csv -NoTypeInformation 

 $Global:Services= $output | select-object SystemName, ServiceName, Servicestate|ConvertTo-Html -Fragment -As Table -PreContent "<h2>Services Compare</h2> " |Out-String
 return $Global:Services
 }




  
 Function Disk-compare
 {
 
 $OldCSV = Import-Csv -Path C:\ostc\Precheck\disk_Pre.csv
 $NewCSV = Import-Csv -Path C:\ostc\Postcheck\disk_Post.csv

 $output = @()

 forEach ($Column in $OldCsv) 
 {      
     $result = $NewCSV | Where-Object {$Column.DeviceID -eq $_.DeviceID} 

           
     if([boolean]$result)
     {

     $DiskTotal1 = if ($Column.'Size (GB)' -ne $result.'Size (GB)') {"Previous: " + $Column.'Size (GB)' + " | Now:" + $result.'Size (GB)'} else{"OK"}
     
     #$DiskUsed = if ($Column.UsedSpaceGB -ne $result.UsedSpaceGB) {"Previous: " + $Column.UsedSpaceGB + " | Now:" + $result.UsedSpaceGB} 

     $DiskFree1 = if ($Column.'Free Space (GB)' -ne $result.'Free Space (GB)') {"Previous: " + $Column.'Free Space (GB)' + " | Now:" + $result.'Free Space (GB)'} else{"OK"}
      
      $output += New-object PSObject -property @{
        SystemName=$Column.SystemName
        volumename =$Column.VolumeName
        DeviceID = $Column.DeviceID
        Size = $DiskTotal1
        FreeSpace = $DiskFree1

      }
       
     }  
   }  
 $output | select-object SystemName,volumename,DeviceID,Size,FreeSpace | Export-Csv -Path C:\OSTC\PostCheck\Disk_Changes.csv -NoTypeInformation 
 $Global:DISk =$output | select-object SystemName,volumename,DeviceID,Size,FreeSpace |
               ConvertTo-Html -Fragment -as Table -PreContent "<h2>Disk Information </h2>"|
               Out-String


return $Global:DISk
}


Function AV-compare
 {
 
 $OldCSV = Import-Csv -Path C:\OSTC\precheck\AVDetails_Pre.csv
 $NewCSV = Import-Csv -Path C:\OSTC\postcheck\AVDetails_Post.csv

 $output = @()

 forEach ($Column in $OldCsv) 
 {      
     $result = $NewCSV | Where-Object {$Column.Version -eq $_.Version} 
           
        

     $AvUpdate = if ($Column.'AV Update Date' -ne $result.'AV Update Date') {"Previous: " + $Column.'AV Update Date'  + " | Now:" + $result.'AV Update Date'} 
                  else {"OK"}
         

      
      $output += New-object PSObject -property @{  
       Version = $Column.Version
       Update = $AvUpdate
       
       
     }  
   }  
 $output | select-object Version,Update | Export-Csv -Path C:\OSTC\Postcheck\AV_Changes.csv -NoTypeInformation 

 $Global:Av =$output | select-object Version,Update |
             ConvertTo-Html -Fragment -As Table -PreContent "<h2> Antivirus Compare Details</h2>"|
             Out-String 

return $Global:Av
}




 
 
 Function Compare-Html
 {
 
   param([Parameter(Mandatory=$false,
          ValueFromPipeline=$true)]
          [string]$FilePath = "C:\users\$env:USERNAME\desktop\Comapre.html",
          #[string]$FilePath = "C:\ostc\precheck\Compare.html",
          

    $Css='<style>table{margin:auto; width:98%}
                  Body{background-color:LightSeaGreen; Text-align:Center;}
                    th{background-color:DarkOrange; color:white;}
                    td{background-color:Lavender; color:Black; Text-align:Center;}
         </style>' ,

        $Css1='<style>table{margin:auto; width:98%}
                  Body{background-color:LightSeaGreen; Text-align:Center;}
                    th{background-color:DarkOrange; color:white;}
                    td{background-color:Lavender; color:Red; Text-align:Center;}
         </style>' )

    Begin{ Write-Verbose "HTML Report will be saved $FilePath" }

    Process
    { 

     $ser=Service-Compare
     $har=Hardware-Compare
     $dis=Disk-compare
     $av=AV-compare

     $Report = ConvertTo-Html -Title "Compared output" `
                             -Head "<h1>Post-Check Compare Report<br><br>$Computername</h1><br>This report was ran: $(Get-Date)" `
                             -Body "$har $dis $av $ser $Css" 
                       
                     
    }

    End{ $Report | Out-File $Filepath ; Invoke-Expression $FilePath }



 }

 Compare-Html





 