#
# Function for combining packer json files
#
function Combine-Packer {
  param(
    [switch]$Run
  )

  $filesToParse = Get-ChildItem | Where-Object {$_.Name -Like "*.packer.json"}
  $filesObject = $filesToParse | Get-Content -Raw | ConvertFrom-Json

  $baseJson = @"
{
    "variables":  {
                  },
    "builders":  [
                 ],
    "provisioners":  [
                     ]
}
"@;
  $baseObject = $baseJson | ConvertFrom-Json

  foreach ($fileObject in $filesObject) {
      $baseObject.variables = $fileObject.variables


      $baseObject.builders += $fileObject.builders
      $baseObject.provisioners += $fileObject.provisioners
  }

  $jsonObject = $baseObject | ConvertTo-Json -Depth 100
  $jsonObject | Out-File -Encoding ascii .\combined.packer -Force

  if ($Run -eq $true) {
    packer build -force -var-file='.\default.uservar.json' .\combined.packer
  }
}