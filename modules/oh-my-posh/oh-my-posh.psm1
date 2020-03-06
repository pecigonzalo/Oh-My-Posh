# Check if profile exists
$INSTALL_PATH = "$HOME/.oh-my-posh"

If ( Test-Path ("$HOME/.oh-my-posh.config.ps1") ) {
  Write-Output "Detected a Oh-My-Posh Profile"
}
else {
  cp "$INSTALL_PATH/template/oh-my-posh.config.ps1" "$HOME/.oh-my-posh.config.ps1"
}

# Load Profile var
. "$HOME/.oh-my-posh.config.ps1"

# Check for updates
. "$INSTALL_PATH/tools/check_for_updates.ps1"

# Execute Oh-My-Powershell
. "$INSTALL_PATH/oh-my-posh.ps1"
