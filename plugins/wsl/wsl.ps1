# Set compatible username across wsl
if ($env:USER) {
  $env:USERNAME = "$env:USER"
}
