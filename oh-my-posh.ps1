# Install modules
& "$Env:USERPROFILE\.oh-my-posh\tools\modules.ps1"

# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Verbose  "Loading from: $Env:USERPROFILE\.oh-my-posh\plugins\$plugin"
  $files = Get-ChildItem $Env:USERPROFILE\.oh-my-posh\plugins\$plugin -Filter *.ps1
  foreach ($file in $files) {
    Write-Verbose  "  Loading file: $($file.FullName)"
    . $file.FullName
  }
}

# Load theme
. "$Env:USERPROFILE\.oh-my-posh\themes\$theme.ps1"
