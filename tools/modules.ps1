#
# Functions to handle modules and installation of them
#
function Install ($Module = "") {
  $Name = $Module.Split(":")[0]
  $Version = $Module.Split(":")[1]

  if ( $Version ) {
    Install-Module -Name $Name -Required $Version -Scope CurrentUser -Force
  } else {
    Install-Module -Name $Name -Scope CurrentUser -Force
  }
}

function Clean ($Modules = "") {
  $Installed_Modules = Get-Module -ListAvailable | Where-Object {$_.Path -like "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules*"}
  foreach ($Installed in $Installed_Modules) {
    if ( $Installed.Name -eq "oh-my-posh" ) {
      # Do not remove myself
    } elseif ( ! ($Modules.Contains($Installed.Name) -or $Modules.Contains("$($Installed.Name):$($Installed.Version.ToString())")) ) {
      $confirmation = Read-Host "This will uninstalling $Installed [y/N]"
      if ($confirmation -ieq "y"){
          Uninstall-Module $Installed -Force
      }
    }
  }
}

# Remove all modules not listed
if ( $Modules_Strict ) {
    Clean($Modules)
}
# Install/Load all modules
foreach ($Module in $Modules) {
  if ($Module) {
    if ( $Modules_Install ) {
      Install($Module)
    }
    try {
      $Name = $Module.Split(":")[0]
      Import-Module $Name -ErrorAction Stop -DisableNameChecking -NoClobber -Global
      Write-Host "Loaded Module $Name"
    } catch {
      Write-Warning $_
    }
  }
}




