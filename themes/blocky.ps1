function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    $Path = $pwd.ProviderPath
    Write-Host " $Path " -NoNewLine -ForegroundColor Black -BackgroundColor White
    if($gitStatus){
        checkGit($Path)
    }
    if ( $realCommandStatus -eq $True ) {
      $BG_EXIT="Green"
    } else {
      $BG_EXIT="Red"
    }
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host "`n > " -NoNewLine -ForegroundColor White -BackgroundColor $BG_EXIT
    return " "
}
