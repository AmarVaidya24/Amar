function connect-site($webs,$creds){ 

 

Connect-PNPonline -Url $webs -Credentials $cred 

 

} 

 

function get-sitepermission($web,$cred)
{ 

$rec=@() 

connect-site -webs $web -creds $cred 


if($web -eq $parentsitename) 
{ 

#Write-Host "Parent site permission" $web 

$Pgroups=Get-PNPGroup 

    foreach($Pgroup in $Pgroups) 
    { 

    #$DLGP = "" | Select "SiteUrl","GroupName","Permission","Users"

    $pPerm=Get-PNPGroupPermissions -Identity $Pgroup.loginname -ErrorAction SilentlyContinue |Where-Object {$_.Hidden -like "False"} 

        if($pPerm -ne $null) 
        { 

        [String]$Pusers= @($Pgroup.users.title -join "`r`n")
        [String]$groupName= $Pgroup.loginname
        [String]$permission= $pPerm.Name
        
        $Obj =New-Object psobject
        $Obj |Add-Member -MemberType NoteProperty -Name SiteUrl -Value $web
        $Obj |Add-Member -MemberType NoteProperty -Name GroupName -Value $groupName
        $Obj |Add-Member -MemberType NoteProperty -Name Permission -Value $permission
        $Obj |Add-Member -MemberType NoteProperty -Name Users -Value $Pusers
        $rec+= $Obj 

        } 

    } 

} 

#$rec

$subwebs=Get-PNPSubWebs 

foreach($subweb in $subwebs) 
{ 

connect-site -webs $subweb.Url -creds $cred 

#Write-Host $subweb.Url 

#$rec=@() 

$groups=Get-PNPGroup

foreach($group in $groups) 
{ 

$groupmember=Get-PnPGroupMembers -Identity $group.Title

#[String]$users =@( $groupmember.Title -join "`r`n")

[String]$users =@( (Get-PnPGroupMembers -Identity $group.Title).Title -join "`r`n")



$sPerm=Get-PNPGroupPermissions -Identity $group.LoginName -ErrorAction SilentlyContinue |Where-Object {$_.Hidden -like "False"} 

if ($sPerm)
{

$obj= New-Object psobject

$obj |Add-Member -MemberType NoteProperty -Name SiteUrl -Value $subweb.Url

$obj |Add-Member -MemberType NoteProperty -Name GroupName -Value $group.loginname  

$obj |Add-Member -MemberType NoteProperty -Name Permission -Value $sPerm.Name

$obj |Add-Member -MemberType NoteProperty -Name Users -Value $users

$rec+=$obj

}

$rec

}

 

}
return $rec

} 

#Input parameter 

$cred=Get-Credential -UserName "admin@sanghu.onmicrosoft.com​" -Message "Enter Credential"

#$parentsitename="https://<tenant-name>.sharepoint.com/sites/contoso" 

$parentsitename="https://sanghu.sharepoint.com"

$outputPath= "C:\Test\AllSubsitegrouppermission.csv" 

$Sitepermission= get-sitepermission -web $parentsitename -cred $cred 

$Sitepermission |Export-Csv -Path $outputPath -NoTypeInformation

$Sitepermission=""