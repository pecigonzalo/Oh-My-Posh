param (
  [bool]$local = $false,
  [bool]$force = $false
)

#
# Utilities
#
function Check-Dependencies {
  $exit = 0
  # Check git installed
  try {
    Get-Command git -ErrorAction Stop | Out-Null
  } catch {
    Write-Error "Git not found, please install git or add it to your PATH before running again"
    $exit = 1
  }
  # If any errors exit install
  if ($exit) { exit 1 }
}

function Check-Recommends {
  # Check PSCX installed
  if (!(Get-Module PSCX -ListAvailable)) {
    Write-Warning "PSCX not found, while not required it is recommended: https://www.powershellgallery.com/packages/Pscx/"
  }
  # Check PSColor installed
  if (!(Get-Module PSColor -ListAvailable)) {
    Write-Warning "PSColor not found, while not required it is recommended: https://github.com/pecigonzalo/pscolor"
  }
}

function Install-OMP {
  Check-Recommends
  Check-Dependencies

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
  New-Item -Type Directory "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules" -Force | Out-Null
  Copy-Item -Recurse -Force $Env:USERPROFILE\.oh-my-powershell\modules\oh-my-powershell  `
    "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"
}

#
# Install logic
#
if ( Test-Path $Env:USERPROFILE\.oh-my-powershell ) {
  Write-Output "Oh-My-Powershell is already installed"
  if ( $force -eq $true ) {
    Write-Output "Reinstalling Oh-My-Powershell"
    Install-OMP
  }
} else {
  Install-OMP
}

