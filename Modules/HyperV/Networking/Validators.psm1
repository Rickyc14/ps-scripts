class ValidateVMSwitchNameAttribute : System.Management.Automation.ValidateArgumentsAttribute
{
    [void]  Validate([object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics)
    {
        $SwitchName = $arguments
        if([string]::IsNullOrWhiteSpace($SwitchName))
        {
            Throw [System.ArgumentNullException]::new()
        }
        if (Get-VMSwitch | Where-Object { $_.Name -eq $SwitchName })
        {
            throw "'$SwitchName' already exists. Please choose a different name."
        }
    }
}
