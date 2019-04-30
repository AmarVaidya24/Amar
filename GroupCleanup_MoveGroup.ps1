function Move_Group
{
	param (
		
		[string]$ADUserSearchBase,
		[String]$DestinationOU,
		[String]$ManageBy
		
	)
	
	$AllEmptyGroups = Get-ADGroup -Filter * -SearchBase $ADUserSearchBase -Properties members, whenChanged | Where-Object { -not $_.members } | where { $_.DistinguishedName -notlike "*CN=Builtin*" -and $_.DistinguishedName -notlike "*$DestinationOU" -and $_.DistinguishedName -notlike "*CN=Users*" }
	
	$AllEmptyGroups = $AllEmptyGroups | Select-Object Name, distinguishedName, WhenChanged | Where-Object { $_.Name -notmatch $Exclude } | Sort-Object Name
	
	Log "Empty groups found in OU $($ADUserSearchBase) : $($AllEmptyGroups.Count)"
	
	# Move empty group and modify description
		
	foreach ($SingleEmptyGroup in $AllEmptyGroups)
	{
		
		$groupDN = $SingleEmptyGroup.distinguishedName
		
		$date = get-date -UFormat '%m/%d/%Y'
		
		[string]$group_creation_timestamp = (get-adgroup -Identity $groupDN -Properties whencreated | select whencreated).whencreated
		
		$group_creation_date = $group_creation_timestamp.split(" ")
		
		$creation_date = $group_creation_date[0] -replace "/", "-"
		
		$difference_in_days = New-TimeSpan -Start $creation_date -End $todays_date
		
		$difference_in_days = $difference_in_days.Days
		
		if ($difference_in_days -gt $global:Exclude_Days) # Group age is greater than Exclusion Days
		{
			
			log "Difference in days is greater than $global:Exclude_Days days" -ForegroundColor "green"
			
			if ($groupDN -match "Territories") #Check if group is in Territories OU Do nothing.
			{
				
				log "$groupDN is in Territories OU" -ForegroundColor "yellow"
				
				
			}			
			else #Group is not in Territories OU
			{
				# Check Group ManageBy
				If($ManageBy -eq "TGITS")
                {
				
				    Set-ADGroup -Identity $groupDN -description "$($group.description) KB0010954!§$date!§$groupDN!§TGITS" -PassThru -Verbose
				
				    try
				    {
					
					    Move-ADObject -Identity $groupDN -TargetPath $DestinationOU
					
					    log "Moved $groupDN to $DestinationOU"
					
				    }
				
				    catch
				    {
					
					    log "Error in moving group $groupDN" "red"
					
				    }
				}
                elseif($ManageBy -eq "Locally")
                {

                Set-ADGroup -Identity $groupDN -description "$($group.description) KB0010954!§$date!§$groupDN!§Locally" -PassThru -Verbose
                
				    try
				    {
					
					    Move-ADObject -Identity $groupDN -TargetPath $DestinationOU
					
					    log "Moved $groupDN to $DestinationOU"
					
				    }
				
				    catch
				    {
					
					    log "Error in moving group $groupDN" "red"
					
				    }


                }
			}
			
		}
		
		else #Newly created group do not do any action
		{
			
			log "Skipping: Difference in days is less than or equal to $global:Exclude_Days days" -ForegroundColor "cyan"
			
		}
		
	}
	
	
	
	
	
	
}