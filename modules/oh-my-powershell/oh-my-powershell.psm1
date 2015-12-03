# Check if profile exists

If ( Test-Path ("$Env:USERPROFILE\.powershellrc.ps1") ) {
    Write-Host "Mock copy a tempalte profile"
}

# Load Profile
. $Env:USERPROFILE"\.powershellrc.ps1"

# Execute Oh-My-Powershell
. "C:\Users\GonzaloP\Workspace\Oh-My-Powershell\powerprofile.ps1"
