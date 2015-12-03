# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Host  "C:\Users\GonzaloP\Workspace\Oh-My-Powershell\plugins\$plugin\$plugin.ps1"
  . "C:\Users\GonzaloP\Workspace\Oh-My-Powershell\plugins\$plugin\$plugin.ps1"
}

# Load theme
If ( $theme -eq $null -or $theme -eq "" ) {
  $theme = "Blocky"
}

. "C:\Users\GonzaloP\Workspace\Oh-My-Powershell\themes\$theme.ps1"
