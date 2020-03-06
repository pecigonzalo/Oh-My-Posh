function global:prompt {
  $realCommandStatus = $?
  $realLASTEXITCODE = $LASTEXITCODE
  $Path = $pwd.ProviderPath
  Write-Host
  Write-Host " $Path " -NoNewLine -ForegroundColor Black -BackgroundColor White
  if ($gitStatus) {
    checkGit($Path)
  }
  if ( $realCommandStatus -eq $True ) {
    $BG_EXIT = "Green"
  }
  else {
    $BG_EXIT = "Red"
  }
  $global:LASTEXITCODE = $realLASTEXITCODE
  Write-Host "`n > " -NoNewLine -ForegroundColor White -BackgroundColor $BG_EXIT
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
