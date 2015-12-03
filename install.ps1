param (
  [bool]$local = $false
)

# Check if Oh-My-Powershell is already installed
if (Test-Path $Env:USERPROFILE\.oh-my-powershell) {
  Write-Host "Oh-My-Powershell is already installed"
} else {
  if ($local) {
      # Deploy from current folder
      rm -Force -Recurse "$Env:USERPROFILE\.oh-my-powershell" -ErrorAction SilentlyContinue
      cp -Recurse -Force .\  "$Env:USERPROFILE\.oh-my-powershell"
    } else {
      # Clone project
      git clone https://github.com/pecigonzalo/Oh-My-Powershell.git $Env:USERPROFILE\.oh-my-powershell
    }
}

# Copy module to the user modules folder
cp -Recurse -Force $Env:USERPROFILE\.oh-my-powershell\modules\oh-my-powershell  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"