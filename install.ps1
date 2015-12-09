param (
  [bool]$local = $false,
  [bool]$force = $false
)

#
# Utilities
#
function Install-OMP {
  Write-Output "Deleting $Env:USERPROFILE\.oh-my-powershell"
  Remove-Item -Force -Recurse "$Env:USERPROFILE\.oh-my-powershell" -ErrorAction SilentlyContinue
  if ($local) {
    # Deploy from current folder
    Write-Output "Coping Oh-My-Powershell to its destination"
    Copy-Item -Recurse -Force .\  "$Env:USERPROFILE\.oh-my-powershell\"
  } else {
    # Clone project
    Write-Output "Cloning Oh-My-Powershell from Github"
    git clone https://github.com/pecigonzalo/Oh-My-Powershell.git $Env:USERPROFILE\.oh-my-powershell
  }
# Copy module to the user modules folder
Write-Output "Installting Oh-My-Powershell Module"
Copy-Item -Recurse -Force $Env:USERPROFILE\.oh-my-powershell\modules\oh-my-powershell  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"
}

#
# Install logic
#

if ( $force -eq $true ) {
  Install-OMP
} else {
  # Check if Oh-My-Powershell is already installed
  if ( Test-Path $Env:USERPROFILE\.oh-my-powershell ) {
    Write-Output "Oh-My-Powershell is already installed"
  } else {
    Install-OMP
  }
}

