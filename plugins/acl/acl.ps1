# SID mapping functions
function Get-SID($stringSid = "") {
  $objSID = New-Object System.Security.Principal.SecurityIdentifier($stringSid) 
  $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
  $objUser.Value
}
function ConvertTo-User($user = "") {
  $objUser = New-Object System.Security.Principal.NTAccount($user) 
  $objSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
  $objSID.Value
}
