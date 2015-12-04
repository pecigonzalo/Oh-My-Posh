# Install modules
. "$Env:USERPROFILE\.oh-my-powershell\tools\modules.ps1"

# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Verbose  "$Env:USERPROFILE\.oh-my-powershell\plugins\$plugin\$plugin.ps1"
  . "$Env:USERPROFILE\.oh-my-powershell\plugins\$plugin\$plugin.ps1"
}

# Load theme
. "$Env:USERPROFILE\.oh-my-powershell\themes\$theme.ps1"
