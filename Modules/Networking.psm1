#Requires -RunAsAdministrator



# Get-NetIPInterface -ConnectionState ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPInterface.ConnectionState]::Connected)


# Get-NetIPInterface -ConnectionState ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPInterface.ConnectionState]::Connected)
#                     -AddressFamily ([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetIPInterface.AddressFamily]::IPv4)


function Set-IPv4
{
    [OutputType([bool])]
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$InterfaceAlias,
        [System.Net.IPAddress]$IPAddress,
        [System.Net.IPAddress]$DefaultGateway
    )

    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway

    # New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress 192.168.10.2 -PrefixLength 24 -DefaultGateway 192.168.10.1
}

