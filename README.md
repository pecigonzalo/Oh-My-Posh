# Oh-My-Powershell
After getting tired of mantaining my powershell profile, i decided to split the components and improve it, as i already use Oh-My-Zsh i tought i would be a good idea to have something similar on Powershell.

Please feel free to submit issues/pull requests/questions/feature reqeusts.

**TODO:**
* ~~Auto Import Modules~~
* Rename to Oh-My-POSH
* Module Dep Management
* ~~More Themes~~
* Add Pester tests
* Properly comment code
* Add info on plugin README.md files
* Add DEBUG/VERBOSE levels and handling
* AutoUpdate handler
* ~~Uninstall script~~

# Installation Instructions

Requires:
* Git
* Powershell 4 (might work with 3 but its not tested)

Run:
```
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/pecigonzalo/Oh-My-Powershell/master/install.ps1'))
```

Add the following line to your powershell profile:
```
Import-Module "Oh-My-Powershell" -DisableNameChecking -NoClobber
```
Now reload your powersell profile

Alternative Installation (local installation):
Download and extract or clone the repository into a folder EG ```C:\TEMP```
Open a powershell session and run
```
cd C:\TEMP
.\install.ps1 -local $true
```

# Configuration

Configuration parameters are found under
```
$env:USERPROFILE\.powershellrc.ps1
```
Open it with your prefered editor and change as you want, keep in mind some functionality is still WIP but dont hesistate on repoting any issue you have.
