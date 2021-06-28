<#
First gets FQDN of VMs from a data file.  Next gets the UUID for each of those
UUIDs and outputs FQDN, UUID.  Useful if somebody asks for UUIDs, but gives 
you a list of VMs FQDN. CMT 24-JUNE-2021
#>

$machines = get-content -Path "C:\Users\q794776\Desktop\Admin\Powershell\data.txt"
$allvms = get-vmguest *
#$logpath =  "C:\Users\q794776\Desktop\Admin\Powershell\logfile.txt"
$vms = @()
$count = 0

#Get valid VM objects from Vcenter
foreach ($machine in $machines){
    $vms = $vms + ($allvms | where-object {$_.hostname -like $machine})
}

#Get UUIDs for valid VM objects and output them with FQDN
foreach ($vm in $vms) {
    $vmuuid = Get-VM $vm.vmname | foreach-object {(Get-View $_.Id).config.uuid} 
    Write-Output "$($machines[$count]), $vmuuid" #| Out-File -FilePath $logpath -Append
    $count++
}