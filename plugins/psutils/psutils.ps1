# Clone psutils if its not present
if (!(Test-Path $PSScriptRoot/psutils)) {
  Write-Host "Installing psutils"
  git clone https://github.com/lukesampson/psutils $PSScriptRoot/psutils
}

# Create an alias for each file to reference the ps1
if (Test-Path $PSScriptRoot/psutils) {
  $files = Get-ChildItem -Filter *.ps1 $PSScriptRoot/psutils
  foreach ($file in $files) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
    Set-Alias -Name $name -Value $file.FullName -Option AllScope -Scope Global
  }
}
