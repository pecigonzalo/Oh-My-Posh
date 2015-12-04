# function Reset-WiFi
# {
#     $adapter = Get-WmiObject Win32_NetworkAdapter | Where { $_.Name.Contains("Wireless") }
#     $wireless.Disable()
#     Sleep(8)
#     $wireless.Enable()
# }

# function Reset-Lan
# {
#     $adapter = Get-WmiObject Win32_NetworkAdapter | Where { $_.Name.Contains("Local") }
#     $wireless.Disable()
#     Sleep(8)
#     $wireless.Enable()
# }

function Get-IPs() {
   $ent = [net.dns]::GetHostEntry([net.dns]::GetHostName())
   return $ent.AddressList | ?{ $_.ScopeId -ne 0 } | %{
      [string]$_
   }
}