<# Parse all VMs in Vcenter and determine which ones are on and off.  Place the ones that are
powered on in the "DC.Name-Powered On" tag.  Also removes tags on those that have been powered off.
Chad Thomsen 6/04/2019#>

#Load VMware PowerCLI modules and snapins
Get-Module -ListAvailable vmware* | Import-Module

$date = get-date
$vcenter = "usrtvcen01"
$logfile = "c:\admin\powershell\vmware\TAG-Script_VMware.txt"
Write-Output "Last executed on $date" | Out-File -FilePath $logfile

#connect to vcenter
connect-viserver -Server $vcenter -Credential (get-storedcredential -Target "TARGET NAME")

foreach ($dc in Get-View -ViewType Datacenter -Property Name, VmFolder) {
    foreach ($vm in Get-View -ViewType VirtualMachine -Filter @{"Summary.Config.Template" = "False"}`
            -SearchRoot $dc.VmFolder -Property Name) { 
        $powered = $null
        $tags = $null
        $tag = $null
        $powered = get-vm $vm.Name | Select-Object -ExpandProperty PowerState
        write-host "Getting tag assignment for VM $($vm.name)"
        $tags = get-tagassignment $vm.name #| Select -ExpandProperty Tag            
        write-host "Tag assignment aquired for VM $($vm.name)"

        Write-Output "VMname is $($vm.name)" | out-file -FilePath $logfile -Append
        Write-Output "Power state is $powered." | out-file -FilePath $logfile -Append
        Write-Output "Datacenter is $($dc.name)." | out-file -FilePath $logfile -Append
        Write-Output "Tags assigned are $($tags.tag.name)" | out-file -FilePath $logfile -Append
        $count = 1
                
        #Check for VM with no tags, but is powered on. If true then tag.
        if ($tags -eq $null -and $powered -eq "PoweredOn") {
            new-tagassignment -entity $vm.Name -Tag "$($dc.Name)-Powered On" | Out-Null
            Write-Output "Added tag assignement $($dc.Name)-Powered On as there were no tags." | out-file -FilePath $logfile -Append
        } 
        else {
            foreach ($tag in $tags) {
                #Check if VM is tagged but has been powered off, and remove tag if true. 
                if ($tag.Tag.Name -eq "$($dc.Name)-Powered On" -and $powered -eq "PoweredOff") {
                    remove-tagassignment -TagAssignment $tag -Confirm:$false | Out-Null
                    Write-Output "Removed tag assignement." | out-file -FilePath $logfile -Append
                    break
                }
                #Check if VM is tagged already and also powered on.  
                elseif ($tag.Tag.Name -eq "$($dc.Name)-Powered On" -and $powered -eq "PoweredOn") {
                    Write-Output "VM is already tagged with $($dc.Name)-Powered On tag." | Out-File -FilePath $logfile -Append
                    break
                }               
                #VM is powered on and we have checked each tag and "DC-Powered On" tag goes not exist, so tag it.  
                elseif ($count -eq $($tags.length) -and $powered -eq "PoweredOn") {
                    new-tagassignment -entity $vm.Name -Tag "$($dc.Name)-Powered On" | Out-Null
                    Write-Output "Added tag assignment $($dc.Name)-Powered On to existing tag list." | Out-File -FilePath $logfile -Append
                }
                #Write-Output "Count = $count"
                #Write-Output "`$tag.length' $($tag.length)"
                #Write-Output "`$powered = $powered"
                $count = $count + 1
            }
        }
        Write-Output " " | Out-File $logfile -Append
    }
}
Disconnect-VIServer -Server * -Force