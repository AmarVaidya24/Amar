#requires -version 2.0

#These are demo commands, this is not a script to run 

Import-Module GroupPolicy

# here's a sample GPO object. We can filter on just about any property
get-gpo -Name "Default Domain Policy"

#GPOs Modified and Created
get-gpo -all | Sort CreationTime,Modificationtime | Select Displayname,*Time

#find all GPOs modified in the last 30 days
get-gpo -all | Where {$_.ModificationTime -ge (Get-Date).AddDays(-30)}

#Automated HTML GPO Reports
help Get-GPOReport
#create a single report
Get-GPOReport -name "Default Domain Policy" -ReportType HTML -Path "c:\work\ddp.htm"
invoke-item "c:\work\ddp.htm"

#create a single report for ALL GPOs
Get-GPOReport -All -ReportType HTML -Path "c:\work\allgpo.htm"
invoke-item "c:\work\allgpo.htm"

#create a single report for each GPO
#replace spaces with _ in the GPO name
::
Get-GPO -all | foreach { 
 $f="{0}.htm" -f ($_.Displayname).Replace(" ","_")
 $htmfile=Join-Path -Path "C:\work" -ChildPath $f
 Get-GPOReport -Name $_.Displayname -ReportType HTML -Path $htmfile
 Get-Item $htmfile 
}
::

#gpos by container. We'll look at the Get-GPOLink script later
::
.\get-gpolink | Sort Container | 
Format-List -GroupBy Container -Property Name,
@{Name="Description";Expression={ (Get-GPO -name $_.Name).Description }},
LinkEnabled,Enforced
::

