#To download DLL. https://www.microsoft.com/en-us/download/details.aspx?id=42038
#SharePoint Cloud Site Collection Permission Report - PowerShell Script

Import-Module 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll'
Import-Module 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll'
Import-Module 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll'


$global:ScriptName = $MyInvocation.MyCommand.Name
$global:ScriptPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$global:IniFileName = "$ScriptPath\Input.ini"


Function Get-IniContent
{
	
	[CmdletBinding()]
	Param (
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ (Test-Path -LiteralPath $_) -and ((Get-Item -LiteralPath $_).Extension -eq ".ini") })]
		[Parameter(ValueFromPipeline = $True, Mandatory = $True)]
		[string]$FilePath
	)
	
	Begin
	{ Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }
	
	Process
	{
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"
		
		$ini = @{ }
		$escapedFilePath = [Management.Automation.WildcardPattern]::Escape($FilePath)
		$IniData = Get-Content $escapedFilePath
		
		switch -regex ($IniData)
		{
			"^\[(.+)\]$" # Section
			{
				$section = $matches[1]
				$ini[$section] = @{ }
				$CommentCount = 0
			}
			"^(;.*)$" # Comment
			{
				if (!($section))
				{
					$section = "No-Section"
					$ini[$section] = @{ }
				}
				$value = $matches[1]
				$CommentCount = $CommentCount + 1
				$name = "Comment" + $CommentCount
				$ini[$section][$name] = $value
			}
			"(.+?)\s*=\s*(.*)" # Key
			{
				if (!($section))
				{
					$section = "No-Section"
					$ini[$section] = @{ }
				}
				$name, $value = $matches[1 .. 2]
				$ini[$section][$name] = $value
			}
		}
		Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"
		Return $ini
	}
	
	End
	{ Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
} # End Function Get-IniContent


$IniFileContent = Get-IniContent $global:IniFileName

$global:SiteName = $($IniFileContent["SiteName"]["Site"])


Function Connect-MySite([string]$SiteURL)
{

    try{

    $username = "UserName"
    $Password = "Password"
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)

    Connect-SPOService -Url $SiteURL -Credential $cred​
    Write-Host "Connected to Sharepoint URL."
    $status= $true
    
    }
    catch
    {
    $status= $false
    Write-Host "Unable to connect to Sharepoint URL."

    }
return $status

}

$Result= Connect-MySite("$global:SiteName")



if($result)
{

$URL1= Get-SPOSite -Limit ALL|select Url


    foreach($URL0 in $URL1)
    {

        $groups = Get-SPOSiteGroup -Site $URL0.Url |where {$_.Roles -ne $null -and $_.users -ne $null}

        Foreach($group in $groups)
        {
            
            Foreach($user in $group.Users)
            {
                        
            $groupL=$group.Title      
            $UserL= $user
            $role = $group.Roles
            $Users_Role =(@($role) -join "`r`n")
        
             New-Object -TypeName PSObject -Property @{
                            Affiliatename=$URL0.Url
                            GroupName = $group.Title
                            UserLogin = $user
                            DisplayName =$group.OwnerTitle
                            UserRole=$Users_Role
                            } | Select-Object Affiliatename,GroupName,UserLogin,DisplayName,UserRole| Export-Csv -Path "$ScriptPath\SPOPermission.csv" -append -NoTypeInformation

                  
            }
        }
        
    }


}
else
{

Write "Unable to capture Details. because we are not connect to Site"

}