# Handle Plugins

foreach ($plugin in $plugins) {
  Write-Host  "C:\Users\GonzaloP\Workspace\PowerProfile\plugins\$plugin\$plugin.ps1"
  . C:\Users\GonzaloP\Workspace\PowerProfile\plugins\$plugin\$plugin.ps1
}
