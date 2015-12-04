###############################################################################
# joonro/Get-ChildItem-Color
# https://github.com/joonro/Get-ChildItem-Color
# Add from https://github.com/JRJurman/PowerLS/blob/master/powerls.psm1
###############################################################################
function Get-ChildItem-Color {
    if ($Args[0] -eq $true) {
        $ifwide = $true

        if ($Args.Length -gt 1) {
            $Args = $Args[1..($Args.length - 1)]
        } else {
            $Args = @()
        }
    } else {
        $ifwide = $false
    }

    if (($Args[0] -eq "-a") -or ($Args[0] -eq "--all")) {
        $Args[0] = "-Force"
    }

    $width =  $host.UI.RawUI.WindowSize.Width
    $color_fore = $host.UI.RawUI.ForegroundColor

    $compressed_list = @(".zip", ".tar", ".gz", ".rar")
    $executable_list = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                         ".psm1", ".vbs", ".rb", ".reg", ".fsx", ".sh")
    $dll_pdb_list = @(".dll", ".pdb")
    $text_files_list = @(".txt", ".csv", ".lg", ".log", ".packer", ".json", ".md", ".pp", ".markdown")
    $configs_list = @(".cfg", ".config", ".conf", ".ini", ".properties", ".gradle", ".gitignore", ".gitattributes")

    $color_table = @{}
    foreach ($Extension in $compressed_list) {
        $color_table[$Extension] = "Yellow"
    }

    foreach ($Extension in $executable_list) {
        $color_table[$Extension] = "Blue"
    }

    foreach ($Extension in $text_files_list) {
        $color_table[$Extension] = "Cyan"
    }

    foreach ($Extension in $dll_pdb_list) {
        $color_table[$Extension] = "Darkgreen"
    }

    foreach ($Extension in $configs_list) {
        $color_table[$Extension] = "Yellow"
    }

    # Handle hiddne files
    $hidden_files = "^\..*$"
    $color_table["hidden_files"] = "DarkGray"

    $i = 0
    $pad = 4

    # get the longest string and get the length
    $childs = Get-ChildItem $Args
    $lnStr = $childs | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
    $len = $lnStr.name.length

    $childs |
    ForEach-Object {
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $c = 'Green'
        } elseif ($_.Name -match $hidden_files) {
            $c = $color_table["hidden_files"]
        } else {
            $c = $color_table[$_.Extension]

            if ($c -eq $none) {
                $c = $color_fore
            }
        }

        if ($ifwide) {
            if ($i -eq -1) {  # change this to `-eq 0` to show DirectoryName
                if ($_.GetType().Name -eq "FileInfo") {
                    $DirectoryName = $_.DirectoryName
                } elseif ($_.GetType().Name -eq "DirectoryInfo") {
                    $DirectoryName = $_.Parent.FullName
                }
                Write-Host ""
                Write-Host -Fore 'Green' ("   Directory: " + $DirectoryName)
                Write-Host ""
            }
            $towrite = $_.Name + (" "*($len - $_.name.length+$pad))
            $count += $towrite.length

            Write-Host $towrite -Fore $c -nonewline

            if ( $count -ge ($width - ($len+$pad)) ) {
              Write-Host ""
              $count = 0
            }
        } else {
            If ($i -eq 0) {  # first item - print out the header
                Write-Host "`n    Directory: $DirectoryName`n"
                Write-Host "Mode                LastWriteTime     Length Name"
                Write-Host "----                -------------     ------ ----"
            }
            $Host.UI.RawUI.ForegroundColor = $c

            Write-Host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode,
                        ([String]::Format("{0,10}  {1,8}",
                                          $_.LastWriteTime.ToString("d"),
                                          $_.LastWriteTime.ToString("t"))),
                        $length, $_.name)

            $Host.UI.RawUI.ForegroundColor = $color_fore

            ++$i # increase the counter
        }
    }
    Write-Host ""
}

function Get-ChildItem-Format-Wide {
    $New_Args = @($true)
    $New_Args += $Args
    Get-ChildItem-Color $New_Args
}

Set-Alias -Name ll -Value Get-ChildItem-Color -option AllScope -Scope Global
Set-Alias -Name ls -Value Get-ChildItem-Format-Wide -option AllScope -Scope Global
