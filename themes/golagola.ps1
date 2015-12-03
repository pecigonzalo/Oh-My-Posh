function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE

    if ( $realCommandStatus -eq $True ) {
      $EXIT="Green"
    } else {
      $EXIT="Red"
    }

    $Path = $pwd.ProviderPath


    Write-Host "$env:USERNAME" -NoNewLine -ForegroundColor Magenta
    Write-Host " @" -NoNewLine -ForegroundColor Yellow
    Write-Host " $Path " -NoNewLine -ForegroundColor Green
    if($gitStatus){
        checkGit($Path)
    }
    Write-Host "`n>" -NoNewLine -ForegroundColor $EXIT


    $global:LASTEXITCODE = $realLASTEXITCODE
    return " "
}
