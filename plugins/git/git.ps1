#
# Create funtion to quickly get git graph
#

try {
    Get-command -Name "git" -ErrorAction Stop >$null
    Import-Module -Name "posh-git" -ErrorAction Stop >$null
    $gitStatus = $true
} catch {
    Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    $gitStatus = $false
}

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
