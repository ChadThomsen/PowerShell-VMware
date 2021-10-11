<#
Looks at resource pools in a Vcenter cluster and adjusts the shares based on criteria you can set and powered on VMs. 
Base code:  https://wahlnetwork.com/2012/02/01/understanding-resource-pools-in-vmware-vsphere
This makes use of the "get-storedcredential" PS module.
CMT 28-JAN-2021
#>

#Load VMware PowerCLI modules and snapins
Get-Module -ListAvailable vmware* | Import-Module

## Variables
[array]$vcenters = <#"usrtvcen01.pharmalinkfhi.com",#> "ca2avcen002p.quintiles.net"
$date = get-date
$logfile = "C:\admin\powershell\vmware\resource-pool-daily-adjust.txt"
#$logfile = "C:\Users\q794776\Desktop\Admin\junk\resource-pool-daily-adjust.txt"

#Authenticate
foreach($vcenter in $vcenters){
    connect-viserver -force -Server $vcenter -Credential (get-storedcredential -Target "vmware-resource") 
    ## Gather Cluster names
    [array]$clusters = get-cluster | select -expandproperty name 

    ## Enumerate Each Cluster
    foreach ($cluster in $clusters){
        write-host "Cluster = $cluster"
        ## Enumerate Members of Resouce Pools in current cluster
        [array]$rpools = Get-ResourcePool -Location (Get-Cluster $cluster)
        Foreach ($rpool in $rpools){
            write-host "rpool = $rpool"
            If ($rpool.name -ne "Resources"){
                #Write-Host -ForegroundColor Green -BackgroundColor Black $rpool.name   
                #[int]$pervmshares = Read-Host "How many shares per VM in the $($rpool.Name) resource pool?"
                if($rpool.name -eq "Prod"){
                    $totalvms = (get-resourcepool $rpool.name | get-vm | where {$_.powerstate -eq "PoweredOn"}).count
                    [int]$pervmshares = 2 
                    [int]$rpshares = $pervmshares * $totalvms 
                    Set-ResourcePool -ResourcePool $rpool.Name -CpuSharesLevel:Custom -NumCpuShares $rpshares -MemSharesLevel:Custom -NumMemShares $rpshares -Confirm:$false | Out-Null 
                } 
                elseif($rpool.name -eq "Dev-QC") {
                    $totalvms = (get-resourcepool $rpool.name | get-vm | where {$_.powerstate -eq "PoweredOn"}).count
                    [int]$pervmshares = 1 
                    [int]$rpshares = $pervmshares * $totalvms
                    Set-ResourcePool -ResourcePool $rpool.Name -CpuSharesLevel:Custom -NumCpuShares $rpshares -MemSharesLevel:Custom -NumMemShares $rpshares -Confirm:$false | Out-Null
                }        
                write-output "$date- Vcenter- $vcenter, Cluster- $cluster, Resource_Pool- $($rpool.name), has $totalvms VMs and was set to $rpshares total shares." | `
                    out-file -filepath $logfile -append
                #Write-Host "$date - Found $totalvms VMs in the $($rpool.name) resource pool. At $pervmshares shares each, setting pool to $rpshares shares."
            }
        }
    }
    disconnect-viserver * -Confirm:$false
}