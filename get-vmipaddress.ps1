<#
Gets IP addresses of VMs listed in an external data file.
CMT 7-April-2021
#>

$hostnames = get-content -path "C:\Users\q794776\Desktop\Admin\Powershell\data.txt"
$vms = get-vmguest *

foreach($hostname in $hostnames){
    foreach($vm in $vms){
        if ($hostname -like $vm.hostname){
            write-host "$($vm.hostname),$($vm.ipaddress)"
        }
    }
}
