<#
Changes IP addresses of Windows VMs.  Please make sure user UAC is turned off for windows 2008R2 and above
https://code.vmware.com/forums/2530/vsphere-powercli#582063
CMT 25-Oct-2019
#>

$VIServer = Read-Host "Enter vCenter Server Name or IP: "
Connect-VIServer $VIServer
 
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials", "", "")
$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials", "", "")
$PrimaryDNS = Read-Host "Primary DNS: "
$SecondaryDNS = Read-Host "Secondary DNS: "
$PrimaryOldWINS = Read-Host "Old Primary WINS: "
$SecondaryOldWINS = Read-Host "Old Secondary WINS: "
$PrimaryWINS = Read-Host "Primary WINS: "
$SecondaryWINS = Read-Host "Secondary WINS: "
$virtual
$virtualmachines = get-vm
 
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip set dns ""Local Area Connection"" static $PrimaryDNS" }
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip add dns ""Local Area Connection"" $SecondaryDNS" }
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip delete wins ""Local Area Connection"" $PrimaryOldWINS" }
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip delete wins ""Local Area Connection"" $SecondaryOldWINS" }
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip add wins ""Local Area Connection"" $PrimaryWINS" }
$virtualmachines |  ForEach-Object{ $_.Name; $_ | Invoke-VMScript -HostCredential $HostCred -GuestCredential `
    $GuestCred -ScriptType "bat" -ScriptText "netsh interface ip add wins ""Local Area Connection"" $SecondaryWINS index=2" }