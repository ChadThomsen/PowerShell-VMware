<#
Gets all Alarms with email actions configured.
CMT 20-APRIL-2021
#>

#Filter Alarms out you don't care about
$alarms = Get-AlarmDefinition | where-object {$_.enabled -eq $true} | 
    where-object {$_.name -notlike "*zerto*" -and $_.name -notlike "*vsan*"} 
$count = 0

#get alarms with email configured 
foreach ($alarm in $alarms){
    $action = Get-AlarmAction -AlarmDefinition $alarm
    #Write-Output "$alarm is configured with $action"
    if($count -eq 0){
        write-output "   *** The following alarms have email configured and are enabled. ***"
    }
    if($action -like "SendEmail"){
        (write-output $alarm | select-object name | format-table -AutoSize -HideTableHeaders -Wrap | 
            out-string -width 4096).trim()
        $email = $action.to
        write-output "     Configured email address: $email"  
    }
    $count = $count + 1
}
write-output " "
$count = 0

#get alarms with no email configured
foreach ($alarm in $alarms){
    $action = Get-AlarmAction -AlarmDefinition $alarm
    if($count -eq 0){
        write-output "   *** The following alarms DO NOT have email configured and are enabled. ***"
    }
    if($action -notlike "SendEmail"){
        (write-output $alarm | select-object name | format-table -AutoSize -HideTableHeaders -Wrap | 
            out-string -width 4096).trim()
    }
    $count = $count + 1
}
write-output " "

#Display alarms that are not enbled
write-output "   *** The following alarms are not enabled. ***"
(Get-AlarmDefinition | where-object {$_.enabled -eq $false} | 
    where-object {$_.name -notlike "*zerto*" -and $_.name -notlike "*vsan*"} | 
    select-object name | format-table -autosize -HideTableHeaders -wrap |
    out-string -width 4096).trim()
    