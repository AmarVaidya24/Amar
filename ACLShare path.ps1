
[cmdletbinding()] 
 
param([Parameter(ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True)]
    $Computer = '.',
    $Filepath="C:\Temp\report.html",

    
    $Css='<style>table{margin:auto; width:98%}
              Body{background-color:LightSeaGreen; Text-align:Center;}
                th{background-color:DarkOrange; color:white;}
                td{background-color:Lavender; color:Black; Text-align:Center;}
     </style>'
    
    
    )  
 
$sh = gwmi -Class win32_share |select Path

$a=@()
  
foreach ($sh1 in $sh) {  
    
    $o=""|select Path,security
    try {  
               
        $ACC=Get-Acl -Path $sh1.path  |select -ExpandProperty Access |select @{name="Security Group";e={$_.identityReference}} 
          
        $ac=""           
        $ACC|foreach{
        $adata =$ACC.'Security Group'
        $ac+="$adata|"

        }              
        $adata
       $o.security=$ac  
       $o.path = $sh1.path 
        } 
    catch  
        { Write-Host "Unable to obtain permissions for $sh1" }  

        $a+=$o
        
    }#End ForEach


    $a | ConvertTo-Html -Fragment -As Table -PreContent "<h2>ACL details</h2>"|Out-String
   
#Get-Acl -Path C:\Windows |select -ExpandProperty Access |select @{name="Security Group";e={$_.identityReference}}

#Get-Acl -Path C:\Windows |select -ExpandProperty Access |select @{name="Security Group";e={$_.identityReference}},fileSystemRight

$Report = ConvertTo-Html -Title "Access Report" `
                         -Head "<h1>PowerShell Reporting<br><br>Report</h1><br>This report was ran: $(Get-Date)" `
                         -Body "$a $Css" 
  
  

 $Report | Out-File $Filepath ; Invoke-Expression $FilePath
    