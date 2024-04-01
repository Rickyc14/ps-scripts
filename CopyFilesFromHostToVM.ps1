#Requires -RunAsAdministrator

# https://learn.microsoft.com/en-us/powershell/module/hyper-v/copy-vmfile


$VM_NAME = 'vmname'

$VM_DESTINATION_PATH = '/home/user/destination_path'

$hostFiles = @(
    'C:\Users\ricar\Downloads\test-file.txt'
)

$guestIntegrationServiceName = 'Guest Service Interface'

$guestServiceInterface = Get-VMIntegrationService -VMName $VM_NAME | Where-Object { $_.Name -eq $guestIntegrationServiceName }

if (!($guestServiceInterface.Enabled))
{
    Write-Warning "Copy-VMFile requires '$guestIntegrationServiceName'. Please enabled it before continuing."
    exit 1
}

foreach ( $file in $hostFiles )
{
    if (Test-Path $file)
    {
        Copy-VMFile -Name $VM_NAME -SourcePath $file -DestinationPath $VM_DESTINATION_PATH -CreateFullPath -FileSource Host -ErrorAction Stop
    }
    else
    {
        Write-Warning "'$file' does not exist."
    }
}
