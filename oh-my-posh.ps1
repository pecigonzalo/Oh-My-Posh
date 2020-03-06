$INSTALL_PATH = "$HOME/.oh-my-posh"

# Install modules
& "$INSTALL_PATH/tools/modules.ps1"

# Handle Plugins
foreach ($plugin in $plugins) {
  Write-Verbose  "Loading from: $INSTALL_PATH/plugins/$plugin"
  $files = Get-ChildItem $INSTALL_PATH/plugins/$plugin -Filter *.ps1
  foreach ($file in $files) {
    Write-Verbose  "  Loading file: $($file.FullName)"
    . $file.FullName
  }
}

# Load theme
. "$INSTALL_PATH/themes/$theme.ps1"
