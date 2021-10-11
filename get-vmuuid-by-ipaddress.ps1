<#
Retrieves VMname, VMUUid, VM ipaddress
CMT 02SEPT2020
#>
#$vms = get-vm | ? {$_.PowerState -eq "PoweredOn"}
$logpath = "C:\Admin\VMware-guest-to-uuid.txt"
$datapath = "C:\Admin\junk\data.txt"
$vmguests = get-vmguest * | Where-Object {$_.state -eq "Running"}

if ("C:\Admin\VMware-uuids.txt"){
    remove-item $logpath
}

$vmaddresses = get-content -path $datapath 

foreach($vmaddress in $vmaddresses){
    $foundip = $null
    #getting name of vm
    foreach($vmguest in $vmguests){
        #if($vmaddress -like "*$($vmguest.ipaddress)*"){
        if($vmguest.ipaddress -contains $vmaddress){        
            $uuid = get-vm $vmguest.vm.name | ForEach-Object {(Get-View $_.Id).config.uuid}
            Write-host "$vmaddress, $($vmguest.vm.name),$uuid" 
            Write-Output "$vmaddress, $($vmguest.vm.name),$uuid" | out-file $logpath -append
            $foundip = $true
        }
    } 
    if($foundip -ne $true){
        write-host "$vmaddress was not found in vcenter."
        Write-Output "$vmaddress was not found in vcenter." | out-file $logpath -append
    }
}