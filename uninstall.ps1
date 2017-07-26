#
# Uninstall Logic
#
Write-Output "Deleting $Env:USERPROFILE\.oh-my-posh"
Remove-Item -Force -Recurse "$Env:USERPROFILE\.oh-my-posh" -ErrorAction SilentlyContinue
Write-Output "Deleting oh-my-posh module"
Remove-Item -Force -Recurse  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\oh-my-posh" -ErrorAction SilentlyContinue
Write-Output "All done, your oh-my-posh config file will be kept, please remember"
Write-Output "to remove the Import-Module logic from your `$PROFILE."