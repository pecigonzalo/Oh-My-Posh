<# Based on norm zsh theme. Check it (https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/norm.zsh-theme) #>

function global:prompt {
  $realCommandStatus = $?
  $realLASTEXITCODE = $LASTEXITCODE
  $lambda = [char]::ConvertFromUtf32(955)
  $forwardArrow = [char]::ConvertFromUtf32(8594)

  if ( $realCommandStatus -eq $True ) {
    $EXIT = "Yellow"
  }
  else {
    $EXIT = "Red"
  }

  $CurrentDirectory = Split-Path -leaf -path (Get-Location)

  Write-Host
  Write-Host "$lambda $env:USERNAME " -ForegroundColor Yellow -NoNewline
  Write-Host "$CurrentDirectory" -NoNewLine -ForegroundColor Green

  if (Get-GitStatus) {
    Write-Host " $forwardArrow $lambda " -ForegroundColor Yellow -NoNewline
    Write-Host "git" -ForegroundColor Blue -NoNewline
    checkGit(Get-Location)
  }

  Write-Host " $forwardArrow" -NoNewLine -ForegroundColor $EXIT
  $global:LASTEXITCODE = $realLASTEXITCODE
  return " "
}

$global:PSColor = @{
  File    = @{
    Default    = @{ Color = 'White' }
    Directory  = @{ Color = 'Green' }
    Reparse    = @{ Color = 'Magenta' }
    Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' }
    Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html|Dockerfile|gradle|
            pp|packergitignore|gitattributes|go|)$'
    }
    Executable = @{ Color = 'Green'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|sh|fsx|)$' }
    Text       = @{ Color = 'Cyan'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|
            xml|yml|md|markdown|properties|json|todo)$'
    }
    Compressed = @{ Color = 'Yellow'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
  }
  Service = @{
    Default = @{ Color = 'White' }
    Running = @{ Color = 'DarkGreen' }
    Stopped = @{ Color = 'DarkRed' }
  }
  Match   = @{
    Default    = @{ Color = 'White' }
    Path       = @{ Color = 'Green' }
    LineNumber = @{ Color = 'Yellow' }
    Line       = @{ Color = 'White' }
  }
}
