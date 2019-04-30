#********************************************************************************#
#*Script to Get the File size from sharepoint library Folders/SubFolders								        *#
#*karim mohammad                                                                *#
#*12.02.2018                                                                    *#
#********************************************************************************#
#IMPORTANT AND CONCERNS
# by running: 
# -Execute below script in windows powershell with elevated permisions[i.e. Run as Administrator] 
# -Sharepoint Web URL
# -Sharepoint List Name
#*******************************************************************************#
Add-PSSnapin Microsot-SharePoint.powershell -ErrorAction SilentlyContinue
$totalsize=0;
$webURL=Read-Host "Enter your web URL"  #Web URL
$web=Get-spweb $webURL
$listName=Read-Host "Enter your List Name"   #list Name
$list=$web.Lists.TryGetList($listName) 
$items=$list.items
$items.count
foreach($file in $items){
if($file.File.Lenght -ne 0 )
{
$totalsize=$totalsize+$file.File.Lenght/1gb
$data=@{
"Item web"=$file.web
"Item ID"=$file.ID
"Item Name"=$file.Name
"Item URL"=$file.URL
"Item size[MB]"=$file.File.Lenght/1mb
"Item size[GB]"=$totalsize
        }
New-Object psobject -Property $data |Export-Csv E:\fileSize.csv -Append		#Export to E:\ Drive
}
}