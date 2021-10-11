<#
Checks status of VM notes, and if the notes per VM do not start with -Purpose then send
an email notifing end user to update them.  6/3/2019 - CMT
#>
import-module VMware.VumAutomation

$toaddress = "to-email@domain.com" 
$servername = "servername"
$fromaddress = "from-emailaddress@doamin.com"
$smptserver = "servername"

$VcenCreds = get-storedcredential -Target $servername 
connect-viserver $servername -credential $VcenCreds -force

$VMs = get-vm * | Where-Object {$_.Notes -notlike "Purpose*"}

if($vms -ne $null){
    [string]$emailsubject = "VMware VM notes need to be updated."
    [string]$emailbody = "VMware VM notes need to be updated since $($VMs.count) VMs notes are not correct."
    Send-MailMessage -To $toaddress -Subject $emailsubject `
        -From $fromaddress -Body $emailbody  -SmtpServer uscasarray
}
else{
    [string]$emailsubject = "VMware VM notes need to be updated."
    [string]$emailbody = "VMware VM notes need to be updated since $($VMs.count) VMs notes are not correct."
    Send-MailMessage -To $toaddress -Subject $emailsubject `
        -From $fromaddress -Body $emailbody  -SmtpServer $smptserver

}
disconnect-viserver -force -confirm:$false