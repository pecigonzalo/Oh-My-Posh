# SID mapping functions
function ConvertTo-User($stringSid = "" {
  $objSID = New-Object System.Security.Principal.SecurityIdentifier($stringSid) 
  $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
  $objUser.Value
}

function ConvertTo-SID($user = "") {
  $objUser = New-Object System.Security.Principal.NTAccount($user) 
  $objSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
  $objSID.Value
}
