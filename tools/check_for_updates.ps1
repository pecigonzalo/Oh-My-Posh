# Load utils
# param (
#   [int]$UpdateAfter
# )
#. ./tools/utils.ps1
# Add current date to store
function Add-CurrentTime {
  Get-Date -Format d | Set-Content "$Env:USERPROFILE/.oh-my-powershell-update"
}

if ($AutoUpdate -eq $true) {
  # Compare current date to last update date
  Write-Host "Checking for Oh-My-Powershell updates"
  if (Test-Path "$Env:USERPROFILE/.oh-my-powershell-update") {
    $oldDate = Get-Content "$Env:USERPROFILE/.oh-my-powershell-update" | Get-Date -Format d

    if ((New-TimeSpan -Start $oldDate -End (Get-Date)).Days -gt $UpdateAfter) {
      $update = 1
    }
  } else {
    Add-CurrentTime
  }
  if ($UpdateAfter -eq 0) { $update = 1 }
  # Call update script
  if ($update){
    Write-Host "Starting update process"
    & "$Env:USERPROFILE\.oh-my-powershell\update.ps1"
    Add-CurrentTime
    $update = 0
  } else {
    "No new updates to be installed"
  }
}


