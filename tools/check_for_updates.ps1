# Load utils
# param (
#   [int]$UpdateAfter
# )
#. ./tools/utils.ps1
# Add current date to store
function Add-CurrentTime {
  Get-Date -Format d | Set-Content "$Env:USERPROFILE/.oh-my-posh-update"
}

if ($AutoUpdate -eq $true) {
  # Compare current date to last update date
  Write-Host "Checking for Oh-My-Posh updates"
  if (Test-Path "$Env:USERPROFILE/.oh-my-posh-update") {
    $oldDate = Get-Content "$Env:USERPROFILE/.oh-my-posh-update" | Get-Date -Format d

    if ((New-TimeSpan -Start $oldDate -End (Get-Date)).Days -gt $UpdateAfter) {
      $update = 1
    }
  } else {
    Add-CurrentTime
  }
  if ($UpdateAfter -eq 0) { $update = 1 }
  # Call update script
  if ($update){
    # Ask for user confirmation about update
    $confirmation = Read-Host "Are you sure you want to update? [y/N]"
    if ($confirmation -ieq "y"){
        Write-Host "Starting update process"
        & "$Env:USERPROFILE\.oh-my-posh\update.ps1"
        Add-CurrentTime
        $update = 0
    } else {
        "Update canceled"
    }
  } else {
    "No updates avaiable"
  }
}


