# Oh-My-Powershell
[![Join the chat at https://gitter.im/pecigonzalo/Oh-My-Powershell](https://badges.gitter.im/pecigonzalo/Oh-My-Powershell.svg)](https://gitter.im/pecigonzalo/Oh-My-Powershell?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

After getting tired of mantaining my powershell profile, I decided to split the components and improve it, as I already use [Oh-My-Zsh](ohmyz.sh) I thought it would be a good idea to have something similar on Powershell.

Please feel free to submit issues/pull requests/questions/feature reqeusts.

# Installation Instructions

Requires:
* Git
* Powershell 4 (might work with 3 but its not tested)

Run:
```powershell
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/pecigonzalo/Oh-My-Powershell/master/install.ps1'))
```

Add the following line to your powershell profile:
```powershell
Import-Module "Oh-My-Powershell" -DisableNameChecking -NoClobber
```
Now reload your Powershell profile

Alternative Installation (local installation):
Download and extract or clone the repository into a folder e.g. ```C:\TEMP```
Open a Powershell session and run
```powershell
cd C:\TEMP
.\install.ps1 -local $true
```

# Configuration

Configuration parameters are found under
```powershell
$env:USERPROFILE\.powershellrc.ps1
```
Open it with your prefered editor and change as you want, keep in mind some functionality is still WIP but don't hesitate on reporting any issue you have.
