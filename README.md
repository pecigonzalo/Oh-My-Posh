# Oh-My-Posh
[![Join the chat at https://gitter.im/pecigonzalo/Oh-My-Posh](https://badges.gitter.im/pecigonzalo/Oh-My-Posh.svg)](https://gitter.im/pecigonzalo/Oh-My-Posh?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

After getting tired of maintaining my PowerShell profile, I decided to split the components and improve it, as I already use [Oh-My-Zsh](ohmyz.sh) I thought it would be a good idea to have something similar for PowerShell.

Please feel free to submit issues/pull requests/questions/feature requests.

# Installation Instructions

Requires:
* Git
* PowerShell 5 (might work with 4 but it's not tested)

Run:

```powershell
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/pecigonzalo/Oh-My-Posh/master/install.ps1'))
```
Note: If running this command throws an error like ``PowerShell_profile.ps1 cannot be loaded because running
scripts is disabled on this system.``

You may need to enable PS Execution Policy, which you can do by running ``Set-ExecutionPolicy -ExecutionPolicy RemoteSigned``

Add the following line to your PowerShell profile:
```powershell
Import-Module "Oh-My-Posh" -DisableNameChecking -NoClobber
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
$HOME/.oh-my-posh.config.ps1
```
Open it with your preferred editor and change as you want, keep in mind some functionality is still WIP but don't hesitate on reporting any issue you have.
