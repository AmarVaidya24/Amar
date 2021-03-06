#requires -version 2.0

<#
 Get GPO Links. This requires the Active Directory Module
 This version does not query for site links
 
 #GPOs Enabled and Disabled
.\get-gpolink
.\get-gpolink | where {-Not $_.LinkEnabled}
#or leverage the pipeline and get the full GPO object
.\get-gpolink | where {-Not $_.LinkEnabled} | Get-GPO

#>

Import-Module ActiveDirectory,GroupPolicy

#define a REGEX pattern for a GUID
[Regex]$RegEx = "(([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12})"

#create an array of distinguishednames
$dn=@()
$dn+=Get-ADDomain | select -ExpandProperty DistinguishedName
$dn+=Get-ADOrganizationalUnit -filter * | select -ExpandProperty DistinguishedName

#get domain and OU links
    
foreach ($container in $dn) {
    
   Get-ADObject -identity $container -properties gplink | 
   Where {$_.GPLink} | foreach {
      $linkData=$_.gplink.split("][") | Where {$_}
     
     foreach ($item in $linkdata) {
         <#
          split the linkdata. Item 0 will contain the GPO GUI
          and Item 1 will contain an value indicating if the link is
          enabled or not and enforced or not
                Enforced  LinkEnabled
              0 no		    yes
              1 no		    no
              2 yes		    yes
              3 yes		    no     
         #>
         
         $gpodata=$item.split(";")
         $guid=$Regex.match($gpodata[0]).Value
         $gponame=(Get-GPO -Guid $guid).Displayname
         
         Switch ($gpodata[1]) {
            0 {$Link=$True;$Enforced=$False}
            1 {$Link=$False;$Enforced=$False}
            2 {$Link=$True;$Enforced=$True}
            3 {$Link=$False;$Enforced=$True}
         } #switch
         
         New-Object -TypeName PSObject -Property @{
            Container=$Container
            Name=$gponame
            ID=$guid
            LinkEnabled=$Link
            Enforced=$Enforced
         } | Select Container,Name,ID,LinkEnabled,Enforced
    } #foreach item
    } #foreach linkdata
} #foreach container