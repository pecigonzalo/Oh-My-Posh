param (
  [bool]$local = $false,
  [bool]$force = $false
)

$INSTALL_PATH = "$HOME/.oh-my-posh"
if ($IsWindows -or !$IsWindows) {
  $SEPARATOR = ";"
}
else {
  $SEPARATOR = ":"
}
$MODULES_PATH = "$env:PSModulePath".Split("$SEPARATOR")[0]

function Test-Dependencies {
  $exit = 0
  # Check git installed
  try {
    Get-Command git -ErrorAction Stop | Out-Null
  }
  catch {
    Write-Error "Git not found, please install git or add it to your PATH before running again"
    $exit = 1
  }
  # If any errors exit install
  if ($exit) { exit 1 }
}

function Install-OMP {
  Test-Dependencies

  Write-Output "Deleting $INSTALL_PATH"
  Remove-Item -Force -Recurse "$INSTALL_PATH" -ErrorAction SilentlyContinue
  if ($local) {
    # Deploy from current folder
    Write-Output "Coping Oh-My-Posh to its destination"
    Copy-Item -Recurse -Force "./"  "$INSTALL_PATH"
  }
  else {
    # Clone project
    Write-Output "Cloning Oh-My-Posh from Github"
    git clone "https://github.com/pecigonzalo/Oh-My-Posh.git" "$INSTALL_PATH"
  }
  # Copy module to the user modules folder
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
    # Load utils
    . "$INSTALL_PATH/tools/utils.ps1"
    Test-Recommends
  }
}
else {
  Install-OMP
}
