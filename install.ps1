param (
  [bool]$local = $false,
  [bool]$force = $false
)

# Load utils
. ./tools/utils.ps1

function Install-OMP {
  Check-Recommends
  Check-Dependencies

  Write-Output "Deleting $Env:USERPROFILE\.oh-my-posh"
  Remove-Item -Force -Recurse "$Env:USERPROFILE\.oh-my-posh" -ErrorAction SilentlyContinue
  if ($local) {
    # Deploy from current folder
    Write-Output "Coping Oh-My-Posh to its destination"
    Copy-Item -Recurse -Force .\  "$Env:USERPROFILE\.oh-my-posh\"
  } else {
    # Clone project
    Write-Output "Cloning Oh-My-Posh from Github"
    git clone https://github.com/pecigonzalo/Oh-My-Posh.git $Env:USERPROFILE\.oh-my-posh
  }
  # Copy module to the user modules folder
  Write-Output "Installting Oh-My-Posh Module"
  New-Item -Type Directory "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules" -Force | Out-Null
  Copy-Item -Recurse -Force $Env:USERPROFILE\.oh-my-posh\modules\oh-my-posh  `
    "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"
}

#
# Install logic
#
if ( Test-Path $Env:USERPROFILE\.oh-my-posh ) {
  Write-Output "Oh-My-Posh is already installed"
  if ( $force -eq $true ) {
    Write-Output "Reinstalling Oh-My-Posh"
    Install-OMP
  }
} else {
  Install-OMP
}
.$PROFILE
