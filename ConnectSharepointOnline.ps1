$username = "Admin@labcloudin.onmicrosoft.com"
$password = "P@ssw0rd3"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force)
Connect-SPOService -Url https://labcloudin-admin.sharepoint.com -Credential $cred
