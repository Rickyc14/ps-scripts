$ProfileFile = "$PSHOME\Profile.ps1"


if (Test-Path -Path $ProfileFile)
{
    Write-Warning "'$ProfileFile' already exists"
}
else
{
    New-Item -ItemType File -Path $ProfileFile
    Set-Content -Path $ProfileFile -Value ""
}