# Check if profile exists

If ( Test-Path ("$Env:USERPROFILE\.powershellrc.ps1") ) {
    Write-Output "Detected a Oh-My-Posh Profile"
} else {
    cp $Env:USERPROFILE"\.oh-my-posh\template\powershellrc.ps1" $Env:USERPROFILE"\.powershellrc.ps1"
}

# Load Profile var
. $Env:USERPROFILE"\.powershellrc.ps1"

# Check for updates
. $Env:USERPROFILE"\.oh-my-posh\tools\check_for_updates.ps1"

# Execute Oh-My-Powershell
. $Env:USERPROFILE"\.oh-my-posh\oh-my-posh.ps1"

