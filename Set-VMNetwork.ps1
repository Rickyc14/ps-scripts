#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory)]
    [string]$VMName,
    [string]$SwitchName,
    [string]$Notes,
    [Parameter(ParameterSetName = "External")]
    [Parameter(ParameterSetName = "Internal")]
    [switch]$Internet,
    [switch]$HostGuest,
    [Parameter(ParameterSetName = "Private")]
    [switch]$Private,
    [Parameter(ParameterSetName = "Internal")]
    [switch]$Internal,
    [Parameter(ParameterSetName = "NAT")]
    [switch]$NAT,
    [Parameter(ParameterSetName = "NAT")]
    [Parameter(ParameterSetName = "Internal")]
    [string]$IPAddress,
    [Parameter(ParameterSetName = "NAT")]
    [UInt32]$PrefixLength,
    [switch]$DisableAllExtensions,
    [switch]$CleanSlate
)


Import-Module -Name .\Modules\HyperV\Networking




if (!$SwitchName) {
    $SwitchName = "TODO: function to get switch name"
}


try {
    $VMInternalSwitch = New-InternalSwitch -SwitchName $SwitchName -ErrorAction Stop
    if ($DisableAllExtensions) {
        Disable-AllSwitchExtensions -SwitchName $VMInternalSwitch.SwitchName
    }
} catch {

}


