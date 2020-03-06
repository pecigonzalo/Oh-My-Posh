param (
  [bool]$local = $false,
  [bool]$force = $false
)

# Load utils
. ./tools/utils.ps1

$INSTALL_PATH = "$HOME/.oh-my-posh"
if ($IsWindows) {
  $SEPARATOR = ";"
} else {
  $SEPARATOR = ":"
}


function Install-OMP {
  Check-Recommends
  Check-Dependencies

  Write-Output "Deleting $INSTALL_PATH"
  Remove-Item -Force -Recurse "$INSTALL_PATH" -ErrorAction SilentlyContinue
  if ($local) {
    # Deploy from current folder
    Write-Output "Coping Oh-My-Posh to its destination"
    Copy-Item -Recurse -Force ./  "$INSTALL_PATH"
  }
  else {
    # Clone project
    Write-Output "Cloning Oh-My-Posh from Github"
    git clone https://github.com/pecigonzalo/Oh-My-Posh.git "$INSTALL_PATH"
  }
  # Copy module to the user modules folder
  $MODULES_PATH = "$env:PSModulePath".Split("$SEPARATOR")[0]
  Write-Output "Installting Oh-My-Posh Module to $MODULES_PATH"
  New-Item -Type Directory "$MODULES_PATH" -Force | Out-Null
  Copy-Item -Recurse -Force "$INSTALL_PATH/modules/oh-my-posh" "$MODULES_PATH"
}

#
# Install logic
#
if ( Test-Path "$INSTALL_PATH" ) {
  Write-Output "Oh-My-Posh is already installed"
  if ( $force -eq $true ) {
    Write-Output "Reinstalling Oh-My-Posh"
    Install-OMP
  }
}
else {
  Install-OMP
}
