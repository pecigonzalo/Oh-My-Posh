#
# Uninstall Logic
#
Write-Output "Deleting $Env:USERPROFILE\.oh-my-powershell"
Remove-Item -Force -Recurse "$Env:USERPROFILE\.oh-my-powershell" -ErrorAction SilentlyContinue
Write-Output "Deleting oh-my-powershell module"
Remove-Item -Force -Recurse  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\oh-my-powershell" -ErrorAction SilentlyContinue
Write-Output "All done, your oh-my-powershell config file will be kept, please remember"
Write-Output "to remove the Import-Module logic from your `$PROFILE."