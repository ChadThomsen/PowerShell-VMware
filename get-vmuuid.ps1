<#
Retrieves VMname, VMUUid, VM ipaddress of all VMS that are powered on. 
CMT 02SEPT2020
#>
$vms = get-vm | where-object {$_.PowerState -eq "PoweredOn"}
$logpath = "C:\users\q794776\Desktop\Admin\VMware-uuids.txt"
if ("C:\users\q794776\Desktop\Admin\VMware-uuids.txt"){
    remove-item $logpath
}

foreach ($vm in $vms) {
    $vmaddress = (Get-VMguest $vm).ipaddress
    $vmuuid = Get-VM $vm | foreach-object {(Get-View $_.Id).config.uuid} 
    Write-Output "$vm, $vmaddress, $vmuuid" | Out-File -FilePath $logpath -Append
}