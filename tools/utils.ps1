#
# Utilities
#

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
