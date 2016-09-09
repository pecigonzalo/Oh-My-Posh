###############################################################################
# psreadline configuration
# http://runas.me/2014/08/28/powershell-console-conemu-psreadline/
# http://www.reddit.com/r/sysadmin/comments/1rit4l/what_do_you_get_when_you_cross_bash_with_cmdexe/cdo3djk
###############################################################################
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

Set-PSReadlineKeyHandler -Key "Ctrl+Delete"       -Function "KillWord"
Set-PSReadlineKeyHandler -Key "Ctrl+Backspace"    -Function "BackwardKillWord"
Set-PSReadlineKeyHandler -Key "Shift+Backspace"   -Function "BackwardKillWord"
Set-PSReadlineKeyHandler -Key "UpArrow"           -Function "HistorySearchBackward"
Set-PSReadlineKeyHandler -Key "DownArrow"         -Function "HistorySearchForward"
Set-PSReadlineKeyHandler -Key "Tab"               -Function "Complete"
Set-PSReadlineKeyHandler -Key "Ctrl+Q"            -Function "TabCompleteNext"
Set-PSReadlineKeyHandler -Key "Ctrl+Shift+Q"      -Function "TabCompletePrevious"

Set-PSReadlineKeyHandler -Key F1 `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
        $node = $args[0]
        $node -is [System.Management.Automation.Language.CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null)
    {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [System.Management.Automation.AliasInfo])
            {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null)
            {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}