#########################################################################################
# Office/Exchange Scripts                                                               #
#########################################################################################

#
# Start Exchange Online
#
function Connect-ExchangeOnline{
  $proxysettings = New-PSSessionOption -ProxyAccessType IEConfig
  $cred = Get-Credential
  $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection -SessionOption $proxysettings -Verbose
  Import-PSSession $s
}
function Connect-ExchangeLocal{
  $cred = Get-Credential
  $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://hqexg02/powershell -Authentication Kerberos -Credential $cred -AllowRedirection -Verbose
  Import-PSSession $s
}

#
# Start Lync Online
#
function Connect-LyncOnline{
  $proxysettings = New-PSSessionOption -ProxyAccessType IEConfig
  $cred = Get-Credential
  $s = New-CsOnlineSession -Credential $cred  -SessionOption $proxysettings -Verbose
  Import-PSSession $s -AllowClobber
}
