# Check if profile exists

if (!$Env:HOME) { $Env:HOME = "$Env:USERPROFILE" }

If ( Test-Path ("$env:HOME\.powershellrc.ps1") ) {
    Write-Host "Mock copy a tempalte profile"
}

# Load Profile
. $env:HOME"\.powershellrc.ps1"

# Execute Oh-My-Powershell
. "C:\Users\GonzaloP\Workspace\Oh-My-Powershell\powerprofile.ps1"
