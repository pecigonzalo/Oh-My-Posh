# Check if profile exists

If ( Test-Path ("$Env:USERPROFILE\.powershellrc.ps1") ) {
    Write-Host "Detected a Oh-My-Powershell Profile"
} else {
    cp $Env:USERPROFILE"\template\.powershellrc.ps1" $Env:USERPROFILE"\.powershellrc.ps1"
}

# Load Profile
. $Env:USERPROFILE"\.powershellrc.ps1"

# Execute Oh-My-Powershell
. $Env:USERPROFILE"\.Oh-My-Powershell\oh-my-powershell.ps1"
