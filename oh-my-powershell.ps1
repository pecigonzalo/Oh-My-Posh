# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Verbose  "$Env:USERPROFILE\.oh-my-powershell\plugins\$plugin\$plugin.ps1"
  . "$Env:USERPROFILE\.oh-my-powershell\plugins\$plugin\$plugin.ps1"
}

# Load theme
If ( $theme -eq $null -or $theme -eq "" ) {
  $theme = "Blocky"
}

. "$Env:USERPROFILE\.oh-my-powershell\themes\$theme.ps1"
