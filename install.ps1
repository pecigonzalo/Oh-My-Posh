# Deploy to home
rm -Force -Recurse "$env:HOME\.oh-my-powershell" -ErrorAction SilentlyContinue
cp -Recurse -Force .\  "$env:HOME\.oh-my-powershell"

# Copy module to the user modules folder
cp -Recurse -Force .\modules\oh-my-powershell  "$([Environment]::GetFolderPath("mydocuments"))\WindowsPowerShell\Modules\"