# Install modules
& "$Env:USERPROFILE\.oh-my-powershell\tools\modules.ps1"

# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Verbose  "Loading from: $Env:USERPROFILE\.oh-my-powershell\plugins\$plugin"
  $files = Get-ChildItem $Env:USERPROFILE\.oh-my-powershell\plugins\$plugin -Filter *.ps1
  foreach ($file in $files) {
    Write-Verbose  "  Loading file: $($file.FullName)"
    . $file.FullName
  }
}

# Load theme
. "$Env:USERPROFILE\.oh-my-powershell\themes\$theme.ps1"
