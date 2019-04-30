#Get-LocalGroup |select name
#Get-LocalUser

$LocalGroupMembers=Get-LocalGroupMember -Group "Administrators"|Select -ExpandProperty Name

$GroupStatus=$LocalGroupMembers|Foreach { IF($_ -eq "CORP\amavaidy"){Write "Present"} }

$GroupStatus



