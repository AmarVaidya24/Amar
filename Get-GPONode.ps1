#requires -version 2.0

#identify what GPO nodes are in use
::
get-gpo -all | 
Sort GPOStatus | 
format-table -GroupBy GPOStatus Displayname,*Time
::

::
get-gpo -all | 
where {$_.GPOStatus -match "disabled"} | 
Select GPOStatus,Displayname
::

get-gpo -all | where {$_.GPOStatus -match "AllSettingsDisabled"}

