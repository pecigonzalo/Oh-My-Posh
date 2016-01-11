# Check if profile exists

If ( Test-Path ("$Env:USERPROFILE\.powershellrc.ps1") ) {
    Write-Output "Detected a Oh-My-Powershell Profile"
} else {
    cp $Env:USERPROFILE"\.oh-my-powershell\template\powershellrc.ps1" $Env:USERPROFILE"\.powershellrc.ps1"
}

# Load Profile var
. $Env:USERPROFILE"\.powershellrc.ps1"

# Check for updates
. $Env:USERPROFILE"\.oh-my-powershell\tools\check_for_updates.ps1"

# Execute Oh-My-Powershell
. $Env:USERPROFILE"\.oh-my-powershell\oh-my-powershell.ps1"

