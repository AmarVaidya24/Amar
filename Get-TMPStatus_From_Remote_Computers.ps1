#Varibale Declaration
$global:ScriptName = $MyInvocation.MyCommand.Name
$global:ScriptNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$global:ScriptPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$Global:LiveServer = New-Object System.Collections.ArrayList
$Global:OfflineServer = New-Object System.Collections.ArrayList
$Global:CopyfailedServer = New-Object System.Collections.ArrayList
#Server Input File.
$servers = Get-Content "$global:ScriptPath\Servers.txt"
$Batchfile = "$ScriptPath\LocalConfig.bat"
$global:taskname = "TPM"
$Global:time = "14:00"
#Store Log file Path
$global:logfile = "$ScriptPath\ScriptLog.log"

################################################################################################
# Functions
################################################################################################

# Log file functions
function log($string, $color)
{
	
	if ($color -eq $null) { $color = "white" }
	
	Write-Host $(Get-Date -format "dd-MMM-yyyy-HH-mm") $string -foregroundcolor $color
	
	$date = $(Get-Date -format "dd-MMM-yyyy HH:mm:ss")
	
	$string = $date + " " + $string
	
	$string | out-file -Filepath "$logfile" -append
	
}



################################################################################################
# Main Code
################################################################################################
# Create Task SChedule on each Server and run it.
foreach($server IN $servers) 
{
   
    
    if(Test-Path "\\$server\C$" -ea SilentlyContinue)
    {
        $Global:LiveServer+=$server

        Copy-Item "$Batchfile" "\\$server\c$"
        
        $PreErrorprefrence=$ErrorActionPreference
        $ErrorActionPreference = 'silentlycontinue'
        $isTaskExist=(schtasks /query /tn "$taskname" /S $server /v /fo CSV | ConvertFrom-Csv | Select-Object -Property "TaskName").TaskName  
        $ErrorActionPreference = $PreErrorprefrence
        
        if( -not $isTaskExist)
        {
            try{

                SchTasks /Create /SC ONCE /S $server /TN $taskname /TR "C:\LocalConfig.bat" /ST $time /ru SYSTEM /RL HIGHEST
                if($? -eq $false)
                {
                    
                    log "$server - Task creation failed" "Red"
                }
                else
                {
                    
                    
                    SchTasks /run /S $server /TN $taskname
                     if($? -eq $false)
                    {
                    
                    log "$server - Task Execution initiation failed" "red"

                    }
                    else
                    {

                    
                   log "$server - Task Execution initiated Success" "Green"

                    }

                }

            }
            catch
            {

            Log "Task Schedule is not Created on $server" 
            
            }

      
        }
        else
        {
        
        schtasks /delete /tn "$taskname" /S $server /F |Out-Null
        Log "Schedule Task $taskname was deleted Successfully from Server:$server" "Yellow"
        
        try{
                Log "Updated New Task is Creating on Server:$server" "Green"
                SchTasks /Create /SC ONCE /S $server /TN $taskname /TR "C:\LocalConfig.bat" /ST $time /ru SYSTEM /RL HIGHEST
                if($? -eq $false)
                {
                    
                    log "$server - Task creation failed" "Red"
                }
                else
                {
                    
                    
                    SchTasks /run /S $server /TN $taskname
                     if($? -eq $false)
                    {
                    
                    log "$server - Task Execution initiation failed" "red"

                    }
                    else
                    {

                    
                   log "$server - Task Execution initiated Success" "Green"

                    }

                }

            }
            catch
            {

            Log "Task Schedule is not Created on $server" 
            
            }


        
        
        }
        
    }
    Else
    {
    
    $Global:OfflineServer +=$server
     Log "Server:$server Is Not Accessible" "Red"
    
    }


}


#offline Server Details

$Global:OfflineServer |Out-File "$ScriptPath\OfflineServers.log"
 
# Collect the Configuration Details From Remote Server.
#Create the Report Folder at Local Server.
$pathExist=Test-Path "$ScriptPath\Report"

if (-not $pathExist)
{

New-Item "$ScriptPath\Report" -ItemType Directory -ErrorAction SilentlyContinue

}

        #Copying Configuration file from each Server.

        foreach($server IN $Global:LiveServer) 
        {
    
            if(Test-Path "\\$server\C$" -ea SilentlyContinue)
            {
            
                $TaskStatus=(schtasks /query /tn "$taskname" /S $server /v /fo CSV | ConvertFrom-Csv | Select-Object -Property "Status").Status
            
                if($TaskStatus -eq "Ready")
                {
                    Copy-Item "\\$server\C$\Report.txt" "$ScriptPath\Report"
                    
                    Rename-Item "$ScriptPath\Report\Report.txt" "$ScriptPath\Report\$server.txt"
                    log "\\$server\C$\Report.txt Moved to LocalDrive."



                }
            }
            else
            {
            log "Failed: To copy file from Path \\$server\C$\Report.txt"
            $Global:CopyfailedServer +=$server

            }
        
        }


        $Global:CopyfailedServer |Out-File "$ScriptPath\CopyingFailedServers.log"



		foreach($server IN $Global:LiveServer) 
        {
    
                
            $inputfile= Get-Content "$ScriptPath\$server.txt"


            $global:IsActivated_InitialValue = $inputfile -match "IsEnabled_InitialValue"
            $global:IsEnabled_InitialValue = $inputfile -match "sEnabled_InitialValue"
            $global:SpecVersion = $inputfile -match "SpecVersion"
           
            
            $Global:Resulthash =[ordered]@{             Server= $server
                                                        IsActivated=$global:IsActivated_InitialValue
                                                        IsEnabled=$global:IsEnabled_InitialValue
                                                        SpecVersion=$global:SpecVersion 
                                                        
                                                        }

            $ResultObj =New-Object psobject -Property $Global:Resulthash

            $ResultObj|Export-Csv "$global:ScriptPath\TPMStatus.csv" -Append -NoTypeInformation

		}

    

#Delete Task Schedule From Remote Server.

foreach($server IN $Global:LiveServer) 
{


$isTaskAllreadyExist=(schtasks /query /tn "$taskname" /S $server /v /fo CSV | ConvertFrom-Csv | Select-Object -Property "TaskName").TaskName
                
    if($isTaskAllreadyExist)
    {
    
        schtasks /delete /tn "$taskname" /S $server /F |Out-Null   

    }

}