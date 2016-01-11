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