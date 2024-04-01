# https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Management/Get-ChildItem

Get-ChildItem -Path "$HOME\Downloads" | Select-Object -Property FullName
