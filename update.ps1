# Go into the installation repository
# Get new code and rebase current changes
$INSTALL_PATH = "$HOME/.oh-my-posh"
if ($IsWindows) {
  $SEPARATOR = ";"
}
else {
  $SEPARATOR = ":"
}
$MODULES_PATH = "$env:PSModulePath".Split("$SEPARATOR")[0]

Push-Location "$INSTALL_PATH"
git pull --rebase --stat origin master
if ($LASTEXITCODE) {
  Pop-Location
  Write-Host "Something went wrong with the git pull, unable to update" -ForegroundColor Red
  exit 1
}
Pop-Location
# Copy module to the user modules folder
Write-Host "Installing Oh-My-Posh Module"
Copy-Item -Recurse -Force "$INSTALL_PATH/modules/oh-my-posh"  `
  "$MODULES_PATH"

# If all good, let the user know
if ($?) {
  Write-Host "Updated Oh-My-Posh successfully!" -ForegroundColor Green
  Write-Host "PLEASE RELOAD YOUR PROFILE DOING: `n.$PROFILE" -ForegroundColor Green
}
else {
  Write-Host "Something went wrong with the update, you might need to reinstall" -ForegroundColor Red
}
