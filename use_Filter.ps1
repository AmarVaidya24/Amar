$testgci = gci
Filter SubDirFilter {if ($_.Name -like "*test*") {$_}}
$test = $testgci |SubDirFilter


$array =@(1..10)
Filter TOP {if($_ -gt "5"){$_}}
$array |TOP


Filter myFilter {If ($_ -eq 1) {$_}}
@(1,2,3) | myFilter



Filter myFilter {
           if($_.Name -eq "notepad.exe") {
             "Found your file: $_"
             Break
            }
}
Get-ChildItem C:\Windows -Recurse -ErrorAction SilentlyContinue | myFilter




Filter myFilter {
           if($_.Name -eq "notepad.exe") {
             "Found your file: $_"
             Break
            }
}


Filter ACL{

if ($_.Account -eq "BUILTIN\Users")
{
"Found:$($_.Account)"
Break

}

}

Get-NTFSAccess C:\Temp |select Account |ACL