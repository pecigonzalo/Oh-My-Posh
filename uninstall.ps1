#
# Uninstall Logic
#
$INSTALL_PATH = "$HOME/.oh-my-posh"
if ($IsWindows) {
  $SEPARATOR = ";"
}
else {
  $SEPARATOR = ":"
}
$MODULES_PATH = "$env:PSModulePath".Split("$SEPARATOR")[0]


Write-Output "Deleting $INSTALL_PATH"
Remove-Item -Force -Recurse "$INSTALL_PATH" -ErrorAction SilentlyContinue
Write-Output "Deleting oh-my-posh module"
Remove-Item -Force -Recurse  "$MODULES_PATH/oh-my-posh" -ErrorAction SilentlyContinue
Write-Output "All done, your oh-my-posh config file will be kept, please remember"
Write-Output "to remove the Import-Module logic from your `$PROFILE."
