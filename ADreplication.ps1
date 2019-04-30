
# Environment Variables
    $Date = $(Get-Date -Format "dd-MMM-yyyy-HH_mm_ss")
    $HTMLReport = "D:\sysadmin\LAB\Report_$date.html"
    $ReportTitle = "SYSVOL DFSR Report"
# Collect Data
    Import-Module ActiveDirectory
    $Array = @()

    #$DCs=Get-ADDomainController -Filter *
    $DCs = Get-Content D:\sysadmin\LAB\servers.txt


    foreach ($dc in $dcs) 
    {
    
    Write-Host "Checking $dc" -ForegroundColor Green
    
    $MyObject = Get-WmiObject -Namespace "root\MicrosoftDFS" -Class DfsrReplicatedFolderInfo -ComputerName $dc 
    If($? -eq $false)
    {

    Write-Host "Unable to connect WMI on $DC" -ForegroundColor red
    
    $MyObject.PSComputerName = $DC

    }
    
    $Array += $MyObject
    
    }
    

    $ResultSet = ($Array | Select-Object @{Name="Domain Controller"; Expression = {$_.PSComputerName}},ReplicatedFolderName,ReplicationGroupName,State |
    #$ResultSet = ($Array | Select-Object @{Name="Domain Controller"; Expression = {$dc}},ReplicatedFolderName,ReplicationGroupName,State |
    ConvertTo-Html -CssUri "D:\sysadmin\LAB\table.css" -Title $ReportTitle -Body "<h1>$ReportTitle</h1>`n<h5>Updated: on $(Get-Date)</h5>") `
    -replace '<td>0</td>', '<td style="background-color: red"><b>0</b></td>' `
    -replace '<td>1</td>', '<td style="background-color: gold"><b>1</b></td>' `
    -replace '<td>2</td>', '<td style="background-color: gold"><b>2</b></td>' `
    -replace '<td>3</td>', '<td style="background-color: gold"><b>3</b></td>' `
    -replace '<td>4</td>', '<td style="background-color: green"><b>4</b></td>' `
    -replace '<td>5</td>', '<td style="background-color: red"><b>5</b></td>' `
#Footer information
$footer = @'
      <table >
      <tr bgcolor='Lavender'> 
      <td colspan='10' height='50' align='center'>
      <p align="justify" class="small"><tab style="white-space:pre">        </tab><b><font color="#003399">Replication State Values</font></b><br>
      <tab style="white-space:pre">        </tab><b>"0 = Uninitialized"</b> <br>
      <tab style="white-space:pre">        </tab><b>"1 = Initialized" </b> <br>
      <tab style="white-space:pre">        </tab><b>"2 = Initial Sync" </b> <br>
      <tab style="white-space:pre">        </tab><b>"3 = Auto Recovery" </b> <br>
      <tab style="white-space:pre">        </tab><b>"4 = Normal" </b> <br>
      <tab style="white-space:pre">        </tab><b>"5 = In Error" </b> <br>
      <br>
      <br>
      <tab style="white-space:pre">        </tab><i><font color="RED" size="4"><b>Note-</font> Please investigate and take the necessary action if the state value in replication status is not 4 (Normal). State 1 and 3 no action can be taken as the recovery is in progress.</b></i> <br>
      </td> </tr>
      </p>

'@ -f (Get-Date -Format D)
#COnverting to HTml
$HTML_Arrar1= $Array1 |ConvertTo-Html -PreContent "<h5>Unable Reach</h5>" -Fragment table |Out-String


# Write Content to Report.
    Add-Content $HTMLReport $ResultSet
    #Add-Content $HTMLReport $MyObject.PSComputerName = $DC
    Add-Content $HTMLReport $footer 
# Call the results or open the file.
    Invoke-Item $HTMLReport 

