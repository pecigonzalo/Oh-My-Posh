###############################################################################
# joonro/Get-ChildItem-Color
# https://github.com/joonro/Get-ChildItem-Color
# Add from https://github.com/JRJurman/PowerLS/blob/master/powerls.psm1
###############################################################################
function Get-ChildItem-Wide {

  $width = $host.UI.RawUI.WindowSize.Width
  $pad = 2

  # get the longest string and get the length
  $childs = Get-ChildItem $Args
  $lnStr = $childs | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
  $len = $lnStr.name.length

  $childs |
  ForEach-Object {
    $output = $_.name + (" "*($len - $_.name.length + $pad))
    $count += $output.length

    Write-Host $output -nonewline

    if ( $count -ge ($width - ($len + $pad)) ) {
      Write-Host ""
      $count = 0
    }
  }
}

Set-Alias -Name ls -Value Get-ChildItem-Wide -option AllScope -Scope Global
