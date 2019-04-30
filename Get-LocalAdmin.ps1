function get-localAdmin 
{  

param ($ComputeName)  
$array=@()
  Foreach($comp in $ComputeName)
  {
    $admins = Gwmi win32_groupuser –computer $comp  -ErrorAction SilentlyContinue

    If($? -eq $true)
    { 
        $admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}  
  

        $Out=$admins |% {
        $_.partcomponent –match “.+Name\=(.+)$” > $nul  
        $matches[1].trim('"') 
        }  

        $user="Domain*"
        

        $array+=$Out |Where {$_ -like $user}
            
        $array    
        
    }
    else
    {
    Write-Host "Server Not Reachable:$comp"
    }

    }
}
get-localAdmin -ComputeName localhost