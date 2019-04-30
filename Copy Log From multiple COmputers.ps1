Get-ChildItem -Path "C:\Windows\CCM\LOGs\" |?{ ((get-date) - $_.creationTime).days -gt 15 }

$Servers=@("1","2")

$Folders=@("One","two")

Foreach ($Server in $Servers)
{


ROBOCOPY "C:\TEST\$Server\" "C:\Test2\$folder" /minage:15 /s /LOG+:c:\$Server + "_robocopy.log"


}

#----------Final Code---------------------------------------------------

$computers=Get-Content C:\test\serverlist.txt



Foreach($computer in $computers)
{

[string]$Parameter="/minage:15 /s /LOG+:c:\test3\robocopy.log"

robocopy "\\$computer\C$\Windows\ccm\logs\" "C:\test3\$computer\" $Parameter



}


