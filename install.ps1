param (
  [bool]$local = $false,
  [bool]$force = $false
)

#
# Utilities
#
function Install-OMP {
  if ($local) {
    # Deploy from current folder
    Write-Host "Deleting $Env:USERPROFILE\.oh-my-powershell"
    rm -Force -Recurse "$Env:USERPROFILE\.oh-my-powershell" -ErrorAction SilentlyContinue
    Write-Host "Coping Oh-My-Powershell to its destination"
    cp -Recurse -Force .\  "$Env:USERPROFILE\.oh-my-powershell"
  } else {
    # Clone project
    Write-Host "Cloning Oh-My-Powershell from Github"
    git clone https://github.com/pecigonzalo/Oh-My-Powershell.git $Env:USERPROFILE\.oh-my-powershell
  }
# Copy module to the user modules folder
Write-Host "Installting Oh-My-Powershell Module"
cp -Recurse -Force $Env:USERPROFILE\.oh-my-powershell\modules\oh-my-powershell  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"
}

#
# Install logic
#

if ( $force -eq $true ) {
  Install-OMP
} else {
  # Check if Oh-My-Powershell is already installed
  if ( Test-Path $Env:USERPROFILE\.oh-my-powershell ) {
    Write-Host "Oh-My-Powershell is already installed"
  } else {
    Install-OMP
  }
}

