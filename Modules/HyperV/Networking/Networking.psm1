#Requires -RunAsAdministrator

function Disable-AllSwitchExtensions
{
    param (
        [Parameter(Mandatory)]
        [string]$SwitchName
    )
    foreach ($SwitchExtension in Get-VMSystemSwitchExtension)
    {
        Disable-VMSwitchExtension -VMSwitchName $SwitchName -Name $SwitchExtension.Name -ErrorAction SilentlyContinue
    }
}

function New-ExternalSwitch
{
    [OutputType([Microsoft.HyperV.PowerShell.VMSwitch])]
    [CmdletBinding(PositionalBinding=$False)]
    param (
        [Parameter(Mandatory)]
        [string]$VirtualSwitchName,
        [string]$PhysicalNetworkAdapterName,
        [string]$VirtualSwitchNotes,
        [switch]$DisableAllExtensions
    )

    if (Get-VMSwitch | Where-Object { $_.Name -eq $VirtualSwitchName })
    {
        Write-Warning "'$VirtualSwitchName' already exists. Please choose a different name."
        return $False
    }

    if ($PhysicalNetworkAdapterName)
    {
        try
        {
            $NetworkAdapter = Get-NetAdapter -Name $PhysicalNetworkAdapterName -ErrorAction Stop
        }
        catch
        {
            Write-Warning "'$PhysicalNetworkAdapterName' is not a valid Network Adapter. Please select a different one."
            return $False
        }
    }
    else
    {
        $NetworkAdapter = Get-NetAdapter -Physical | Sort-Object -Property LinkSpeed -Descending | Select-Object -First 1
    }

    $ExternalVMSwitchArguments = @{
        AllowManagementOS = $True
        ComputerName =  $env:COMPUTERNAME
        MinimumBandwidthMode = [Microsoft.HyperV.PowerShell.VMSwitchBandwidthMode]::Weight
        Name = $VirtualSwitchName
        NetAdapterName = $NetworkAdapter.Name
        Notes = $VirtualSwitchNotes
    }

    Write-Information "Trying to connect '$VirtualSwitchName' to $($NetworkAdapter.Name), $($NetworkAdapter.InterfaceDescription)..."

    try
    {
        New-VMSwitch @ExternalVMSwitchArguments -ErrorAction Stop
    }
    catch
    {
        Write-Warning "Could not create external switch: $($_.Exception.Message)"
        return $False
    }

    if ($DisableAllExtensions)
    {
        Disable-AllVMSwitchExtensions $VirtualSwitchName
    }

    Write-Information "'$VirtualSwitchName' external switch has been successfully created!"

    return $True
}

function New-InternalSwitch {
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess)]
    [OutputType([Microsoft.HyperV.PowerShell.VMSwitch])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateVMSwitchNameAttribute()]
        [string]$Name,
        [string]$Notes,
        [switch]$SkipUniqueness
    )
    process {
        $InternalVMSwitchArguments = @{
            ComputerName = $env:COMPUTERNAME
            MinimumBandwidthMode = [Microsoft.HyperV.PowerShell.VMSwitchBandwidthMode]::Absolute
            Name = $Name
            Notes = $Notes
            SwitchType = [Microsoft.HyperV.PowerShell.VMSwitchType]::Internal
        }
        Write-Information "Creating new internal switch: '$Name'..."
        New-VMSwitch @InternalVMSwitchArguments
    }
}

function New-VMNAT {
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess)]
    param(
        # [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$VMName,
        [string]$NATName,
        [string]$SwitchName,
        [Microsoft.HyperV.PowerShell.VMSwitch]$Switch
    )
    process {
        if (!$PSBoundParameters.ContainsKey("Switch")) {
            $Switch = New-InternalSwitch -Name $SwitchName
        }
        $SwitchID = $Switch | Select-Object -ExpandProperty Id
        $VMAdapter = Get-VMNetworkAdapter -All | Where-Object -FilterScript { $_.SwitchId -eq $SwitchID }
        $Adapter = Get-NetAdapter | Where-Object -FilterScript { $_.MacAddress.Replace("-", "") -eq $VMAdapter.MacAddress }
        $NETArguments = @{
            InterfaceIndex = $Adapter.InterfaceIndex
            IPAddress = 192.168.0.1
            PrefixLength = 24
            DefaultGateway = 192.168.0.5
        }
        $InternalIPInterfaceAddressPrefix = $NETArguments.IPAddress, $PrefixLength -join "/"
        New-NetIPAddress @NETArguments
        New-NetNAT -Name $NATName -InternalIPInterfaceAddressPrefix $InternalIPInterfaceAddressPrefix
        Add-VMNetworkAdapter -VMName $VMName -SwitchName $Switch.Name
    }
}

function Remove-AllNetworkAdapters
{
    # > Get-VMNetworkAdapter -All | select IsExternalAdapter, Connected, Name, VMName
    #
    # Add Warning message if removing External network connected to wifi adapter (go to adapter settings and "remove bridge"!)
    #
    foreach ($adapter in Get-VMNetworkAdapter -All | Where-Object -FilterScript { !($_.Connected) })
    {
        Remove-VMNetworkAdapter -VMNetworkAdapter $adapter -ErrorAction SilentlyContinue
    }
}

function Remove-AllVMNetworkAdapters
{
    #
    # Add Warning message if removing External network connected to wifi adapter (go to adapter settings and "remove bridge"!)
    #

    [Parameter(Mandatory)]
    param($VMName)

    foreach ($adapter in Get-VMNetworkAdapter -VMName $VMName)
    {
        Remove-VMNetworkAdapter -VMName $VMName -Name $adapter.Name -ErrorAction SilentlyContinue
    }
}

function Remove-AllSwitches
{
    Remove-VMSwitch -VMSwitch (Get-VMSwitch) -Force -ErrorAction SilentlyContinue
}

function Remove-AllVMSwitches {
    [Parameter(Mandatory)]
    param($VMName)
    Remove-VMSwitch -Name -Force -ErrorAction SilentlyContinue |
        Get-VMNetworkAdapter -All |
            Where-Object -FilterScript { $_.VMName -eq $VMName } |
                Select-Object -Property SwitchName
}

function Clear-VMNetworking {
    [Parameter(Mandatory)]
    param($VMName)
    Remove-AllVMNetworkAdapters $VMName
    Remove-AllVMSwitches $VMName
}
