#Veriable decleration 

$logfile = "Delegated_OU_Owner_$(Get-Date -format "dd-MMM-yyyy-HH-mm").log"
Import-Module ActiveDirectory

#Function Decleration 
Function Get-DelegatedOU
{

$delegatedOU = Get-ADOrganizationalUnit -Filter * -Properties businessCategory |?{$_.businessCategory -like "DelegatedOU*"} |select -ExpandProperty DistinguishedName

$hash = @{}
foreach( $SingleDOU in $delegatedOU)
{ 

$DOU = (($SingleDOU  -split ',', 3)[0]) -replace "OU="
$Zone =(($SingleDOU  -split ',', 4)[2]) -replace "OU="

$hash.Ou =$SingleDOU
$hash.DelegatOu = $DOU
$hash.Zone =$Zone

$object = New-Object PSObject -Property $hash
$object |Export-Csv C:\TEMP\delegatedou.csv -NoTypeInformation -Append 
log "Delegated OU Information Captured and Store at c:\temp\DelegatedOU.csv"

}

}

function log($string, $color)
{
	
	if ($color -eq $null) { $color = "white" }
	
	Write-Host $(Get-Date -format "dd-MMM-yyyy-HH-mm") $string -foregroundcolor $color
	
	$date = $(Get-Date -format "dd-MMM-yyyy HH:mm:ss")
	
	$string = $date + " " + $string
	
	$string | out-file -Filepath "C:\Temp\$logfile" -append
	
}



Function Get-Owner
{


Param(
[String]$OU,
[String]$Branch

)

#Write-Host "$OU -> $Branch"

#testing 
#$OU=$($Data[0].OU)
Log "Wokring on OU:$Ou"
Log "Wokring on OU Branch:$Branch"
#
$obj=@()

$GroupOU="OU=Groups,$ou"
#write $GroupOU

Cd AD:
log "Check if Group OU is Exist."
if([adsi]::Exists("LDAP://$GroupOU"))
{
    #Write-Host "Group ou exist"
    #Get ACL Details of Group 
    Log "Checking ACL Details."
    $OUACLs =(Get-Acl -Path $GroupOU | select -ExpandProperty Access | select -ExpandProperty IdentityReference | select -Unique).Value

    #Group Name Must be in DG-*-GroupManagers Formate.
    $checkGROUP= "DG-$Branch-GroupManagers"
    Log "Checking $checkGROUP Is Present in ACL list."

    #$checkGROUP Present in ACL List.
    $filterGroup= $OUACLs |Where-Object{($_ -like "*$checkGROUP")}
    Log "Group Found in $filterGroup ACL list"

    #IF group list is not empty.
    IF($filterGroup)
    {
        log "Checking AL and AJ User account in Group."
        #group Membere Details.
        $DG_GroupMembers = (Get-ADGroupMember -Identity $checkGROUP  -Recursive) |?{($_.SamAccountName -match "^AL$*") -or ($_.SamAccountName -match "^AJ$*")}
                
        #Total recursive users found in Group.
        $TotalUsers =$DG_GroupMembers.Count
        Log "Total Number of Users: $TotalUsers"
        
        #Users not part of ITOP OU 
        $DGUsers_notInITOP =$DG_GroupMembers -notmatch "ITOP"

        $NotTGITSUsers = $DGUsers_notInITOP.Count

        
        Log "Seraching Branch details"
        #Find Users Branch details and check Count.
        $ITOPCount=$DG_GroupMembers.distinguishedName |findstr "ITOP"
        $EPCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]EP*"        
        $HDCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]HD*"                   
        $RMCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]RM*"
        $TPCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]TP*"
        $GPCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]GP*"
        $TECount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]TE*"
        $ENCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]EN*"
        $RCCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]RC*"
        $MSCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]MS*"
        $ABCount=$DGUsers_notInITOP.distinguishedName -like "*OU=[A-Z][A-Z]AB*"
        
     
    }

    Log "Check Total users count is not Zero."
    If($TotalUsers -gt 0)
    {
    log "Percent calculater"
    $ITOPPercent = ($ITOPCount.Count/$TotalUsers).tostring("P")
    $HDPercent = ($HDCount.Count/$TotalUsers).tostring("P")
    $EPPercent = ($EPCount.Count/$TotalUsers).tostring("P")
    $RMPercent = ($RMCount.Count/$TotalUsers).tostring("P")
    $TPPercent = ($TPCount.Count/$TotalUsers).tostring("P")
    $GPPercent = ($GPCount.Count/$TotalUsers).tostring("P")
    $TEPercent = ($TECount.Count/$TotalUsers).tostring("P")
    $ENPercent = ($ENCount.Count/$TotalUsers).tostring("P")
    $RCPercent = ($RCCount.Count/$TotalUsers).tostring("P")
    $MSPercent = ($MSCount.Count/$TotalUsers).tostring("P")
    $ABPercent = ($ABCount.Count/$TotalUsers).tostring("P")
    }
    else
    {
    log "No user Found in Group"
    $ITOPPercent = "0"
    $HDPercent = "0"
    $EPPercent = "0"
    $RMPercent = "0"
    $TPPercent = "0"
    $GPPercent = "0"
    $TEPercent = "0"
    $ENPercent = "0"
    $RCPercent = "0"
    $MSPercent = "0"
    $ABPercent = "0"

    }

   


    $obj = New-Object -Type PSObject -Property (
 [ordered] @{
   "OU"  = $OU
   "ITOP"= $ITOPPercent 
   "HD" = $HDPercent 
   "EP" = $EPPercent 
   "Tp" = $EPPercent
   "GP" = $EPPercent
   "TE" = $EPPercent
   "EN" = $EPPercent
   "RC" = $EPPercent
   "MS" = $EPPercent
   "AB" = $EPPercent
    }
 )

 #$obj

    #"ITOP=$ITOPPercent","HD=$HDPercent","EP=$EPPercent","RM=$RMPercent","TP=$TPPercent","Gp=$GPPercent","TE=$TEPercent","EN=$ENPercent","RC=$RCPercent","MS=$MSPercent","AB=$ABPercent"

}
else
{
#Write-Host "OU Not Exist."
Log "OU Not Exist"
}

CD C:



return $obj



}


#Get-Owner -OU $($Data[0].OU) -Branch $($Data[0].DelegatOu)

Get-DelegatedOU
$Data= Import-Csv C:\Temp\delegatedou.csv

For($i=0; $i -lt $Data.Count;$i++)
{

$Report = Get-Owner -OU $($Data[$i].OU) -Branch $($Data[$i].DelegatOu)

$Report |Epcsv -Path C:\Temp\FinalReport.csv -NoTypeInformation -Append
}

 