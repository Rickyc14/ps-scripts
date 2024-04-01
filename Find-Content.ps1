
$ExcludeBinaries = @("*\\packages\", "*\bin\", "*\obj\")

$PowerShellFileExtensions = @("ps1", "psm1", "psd1", "ps1xml", "pssc", "psrc", "cdxml") |
    ForEach-Object -Process { "*.$_"}



$SearchPath = @(
    "C:\Dev\"
)

$SearchPattern = @(
    "Scripts"
)

Get-ChildItem -Path $SearchPath -Recurse -File -Exclude $ExcludeBinaries |
    Select-String -Pattern $SearchPattern -SimpleMatch:$false -CaseSensitive:$true |
        Format-List -Property Path, LineNumber, Line

# Get-ChildItem -Path $SearchPath -Recurse -File -Include $PowerShellFileExtensions |
#     Select-String -Pattern $SearchPattern -SimpleMatch:$false -CaseSensitive:$true |
#         Format-List -Property Path, LineNumber, Line


# Get-ChildItem -Recurse -Exclude "*.ico", "*.svg", "*.eot", "*.ttf", "*.woff", "*.woff2", "*.js", "*.css", "*.map", "*.dll", "*.exe", "*.cache" | Select-String "scripts"
