$VSCodeSettingsFile = "$Env:APPDATA\Code\User\settings.json"


$VSCodeSettingsFileContent = @"
{
    "workbench.startupEditor": "none",
    "workbench.editor.wrapTabs": true,
    "telemetry.telemetryLevel": "off",
    "files.trimTrailingWhitespace": true
}
"@


Set-Content -Path $VSCodeSettingsFile -Value $VSCodeSettingsFileContent