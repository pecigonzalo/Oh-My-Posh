try {
    Get-command -Name "git" -ErrorAction Stop >$null
    if (Get-Module "posh-git") {
        $gitStatus = $true
    } else { throw }
} catch {
    Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    $gitStatus = $false
}

#
# Create funtion to quickly get git graph
#
function gitlog {
  git log --oneline --all --graph --decorate -n 30
}

function checkGit($Path) {
    if (Test-Path -Path (Join-Path $Path '.git/') ) {
        Write-VcsStatus
        return
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        checkGit($SplitPath)
    }
}
