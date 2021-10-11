<#
This Script backups up all hosts that are in the hosts.txt data file.
Chad Thomsen https://kb.vmware.com/s/article/2042141 12/06/2019
#>
import-module VMware.VimAutomation.Core

#Backup hypervisior configs
$hypervisors = get-content .\hosts.txt
$vcenters = get-content .\vcenters.txt
$backuppath = "C:\admin\Backups\vmware"
$ftppassword = get-storedcredential -Target "target name"
$vcencreds = get-storedcredential -Target "target-name"
$esxicreds = get-storedcredential -Target "target-name"


remove-item c:\admin\backups\vmware\old\*.tgz
move-item c:\admin\Backups\vmware\*.tgz C:\admin\Backups\vmware\old

foreach($hypervisor in $hypervisors){
    connect-viserver -server $hypervisor -credential $esxicreds
    get-vmhostfirmware -vmhost $hypervisor -BackupConfiguration -DestinationPath $backuppath 
    Disconnect-VIServer -Server $hypervisor -Confirm:$false
}

<#
#backup vcenters
#https://blogs.vmware.com/PowerCLI/2018/07/automate-file-based-backup-of-vcsa.html
foreach($vcenter in $vcenters){
    # Login to the CIS Service of the desired VCSA
    Connect-CisServer -Server $vcenter #-Credential $vcencreds

    # Store the Backup Job Service into a variable
    $backupJobSvc = Get-CisService -Name com.vmware.appliance.recovery.backup.job
    
    # Create a specification based on the Help response
    $backupSpec = $backupJobSvc.Help.create.piece.CreateExample()
    
    # Fill in each input parameter, as needed
    $backupSpec.parts = @("common")
    $backupSpec.location_type = "FTP"
    $backupSpec.location = "ftp01.corp.local"
    $backupSpec.location_user = "backup"
    [VMware.VimAutomation.Cis.Core.Types.V1.Secret]$backupSpec.location_password = "VMware1!"
    $backupSpec.comment = "PowerCLI Backup Job"
 
# Create the backup job 
$backupJobSvc.create($backupSpec)
}
#>
write-host "Backups has been compeleted."