<#
Gets hostname of VMs from IP addresses in an external data file.  Is handy to use when 
reverse DNS lookup fails. 
CMT 24-SEPT-2021
#>

$ipaddresses = get-content -path "C:\Admin\Powershell\data.txt"
$vms = get-vmguest *
$totalvms = $vms.Count - 1
$ipcounter = 0
if(test-path output.txt) {remove-item output.txt -Force}
foreach($ipaddress in $ipaddresses){
    #write-output "---------- $ipcounter -------------" | out-file -Filepath output.txt -Append
    $vmcounter = 0
    $break = $null
    foreach($vm in $vms){
        #Checking for multiple IPs per VM. 
        $vmcounter = $vmcounter + 1
        for($index=0; $index -le $vm.IPAddress.Count; $index++){
            if ($ipaddress -like $vm.ipaddress[$index]){
                #write-host "$ipaddress, $($vm.hostname)"
                write-output "$ipaddress, $($vm.hostname)" | out-file -FilePath output.txt -Append
                $break=$true
                break
            }
            elseif ($vmcounter -eq $totalvms -and $break -ne $true -and $index -eq $vm.ipaddress.count){
                #write-host "$ipaddress, Name could not be found."
                write-output "$ipaddress, Name could not be found." | out-file -Filepath output.txt -Append
            }
        }
   }
    $ipcounter = $ipcounter + 1
}