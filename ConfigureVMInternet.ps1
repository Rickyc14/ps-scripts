#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateVMSwitchExistsAttribute()]
    [string]$Name,
    [string]$Notes
)

Import-Module -Name .\Modules\HyperVNetworkUtils.psm1


# Clean Slate (Optional)
#
# Remove-AllVMNetworkAdapters
# Remove-AllVMSwitches


$VMName = "Ubuntu 22.04 LTS (MS Hyper-V)"

$InternalSwitchArguments = @{
    VirtualSwitchName = "Custom Internal Switch"
    VirtualSwitchNotes = "Custom Internal Switch"
    DisableAllExtensions = $True
    InformationAction = [System.Management.Automation.ActionPreference]::Continue
}

$ExternalSwitchArguments = @{
    VirtualSwitchName = "Custom External Switch"
    VirtualSwitchNotes = "Custom External Switch"
    DisableAllExtensions = $True
    InformationAction = [System.Management.Automation.ActionPreference]::Continue
}

$NetworkIPArguments = @{
    IPAddress = "192.168.10.1"
    # IPAddress = "192.168.10.2"
    PrefixLength = 24
    # This interface will work as the Default Gateway
    # DefaultGateway = "192.168.10.1"
}


# Clean Slate (Optional)
#
# Remove-AllNetworkAdaptersFromVM $VMName


# TODO: add log about external Switch creating a Bridge<=>Wi-Fi and steps to remove it (if New-ExternalSwitch fails)
$VMInternalSwitch = New-InternalSwitch @InternalSwitchArguments
$VMExternalSwitch = New-ExternalSwitch @ExternalSwitchArguments

if ($true)
{

    #
    # Wait 30 seconds...?
    #

    # Problem: Switches are not required to have unique names!
    $VMNetworkAdapter = Get-VMNetworkAdapter -All | Where-Object { $_.SwitchName -eq $InternalSwitchArguments.VirtualSwitchName }


    $MACAddress = $VMNetworkAdapter.MacAddress -replace '..(?!$)', '$&-'
    $NetworkAdapter = Get-NetAdapter | Where-Object { $_.MacAddress -eq $MACAddress }
    $NetworkIPArguments.Add("InterfaceAlias", $NetworkAdapter.InterfaceAlias)
    New-NetIPAddress @NetworkIPArguments
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $InternalSwitchArguments.VirtualSwitchName
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $ExternalSwitchArguments.VirtualSwitchName


    Write-Output "[ 1 ] Go to Settings > Network & Internet > Advanced network settings > Advanced sharing settings > Public networks and enable 'File and printer sharing'."
    Write-Output "`tThis will enable communication from Guest -> Host (a.k.a. Hyper-V guest will be able to ping Hyper-V host)."

    Write-Output "[ 2 ] Go to Control Panel > Network and Internet > Network Connections (Change adapter settings), right-click $($ExternalSwitchArguments.VirtualSwitchName)` and click on settings."
    Write-Output "Then go to 'Sharing', enable 'Allow other network users to connect through this computer's internet connection' and choose $($InternalSwitchArguments.VirtualSwitchName)."

    Write-Output "[ 3 ] Now go on your VM and set its IP Address (Internal Switch) to $($NetworkIPArguments.IPAddress.Split(".")[0..2] -join ".").*/$($NetworkIPArguments.PrefixLength) (Default Gateway: $($NetworkIPArguments.IPAddress))"

    Write-Output "[ 4 ] Finally, set the external switch to DHCP"
}
