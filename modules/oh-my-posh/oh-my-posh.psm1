# Check if profile exists

If ( Test-Path ("$Env:USERPROFILE\.posh.config") ) {
    Write-Output "Detected a Oh-My-Posh Profile"
} else {
    cp $Env:USERPROFILE"\.oh-my-posh\template\posh.config.ps1" $Env:USERPROFILE"\.posh.config"
}

# Load Profile var
. $Env:USERPROFILE"\.posh.config"

# Check for updates
. $Env:USERPROFILE"\.oh-my-posh\tools\check_for_updates.ps1"

# Execute Oh-My-Powershell
. $Env:USERPROFILE"\.oh-my-posh\oh-my-posh.ps1"

