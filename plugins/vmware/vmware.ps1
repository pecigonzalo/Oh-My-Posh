if ((Get-PSSnapin -Name VMware.VimAutomation.Core -Registered -ErrorAction SilentlyContinue) -eq $null)
{
  $EnableVMWarePS = $False
} else {
  $EnableVMWarePS = $true
}

if ($EnableVMWarePS -eq $true) {
    #
    #Load Vsphere Powercli modules
    #

    #VMWare variables
    $CustomInitScriptName = "Initialize-PowerCLIEnvironment_Custom.ps1"
    $currentDir = "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts"
    $CustomInitScript = Join-Path $currentDir $CustomInitScriptName

    #
    #returns the version of Powershell
    # Note: When using, make sure to surround Get-PSVersion with parentheses to force value comparison
    function Get-PSVersion {
        if (test-path variable:psversiontable) {
        $psversiontable.psversion
      } else {
        [version]"1.0.0.0"
      }
    }

    # Returns the path (with trailing backslash) to the directory where PowerCLI is installed.
    function Get-InstallPath {
       $regKeys = Get-ItemProperty "hklm:\software\VMware, Inc.\VMware vSphere PowerCLI" -ErrorAction SilentlyContinue

       #64bit os fix
       if($regKeys -eq $null){
          $regKeys = Get-ItemProperty "hklm:\software\wow6432node\VMware, Inc.\VMware vSphere PowerCLI"  -ErrorAction SilentlyContinue
       }

       return $regKeys.InstallPath
    }

    # Loads additional snapins and their init scripts
    function LoadSnapins(){
       $snapinList = @( "VMware.VimAutomation.Core", "VMware.VimAutomation.License", "VMware.DeployAutomation", "VMware.ImageBuilder", "VMware.VimAutomation.Cloud")

       $loaded = Get-PSSnapin -Name $snapinList -ErrorAction SilentlyContinue | % {$_.Name}
       $registered = Get-PSSnapin -Name $snapinList -Registered -ErrorAction SilentlyContinue  | % {$_.Name}
       $notLoaded = $registered | ? {$loaded -notcontains $_}

       foreach ($snapin in $registered) {
          if ($loaded -notcontains $snapin) {
             Add-PSSnapin $snapin
          }

          # Load the Intitialize-<snapin_name_with_underscores>.ps1 file
          # File lookup is based on install path instead of script folder because the PowerCLI
          # shortuts load this script through dot-sourcing and script path is not available.
          $filePath = "{0}Scripts\Initialize-{1}.ps1" -f (Get-InstallPath), $snapin.ToString().Replace(".", "_")
          if (Test-Path $filePath) {
             & $filePath
          }
       }
    }
    LoadSnapins

    function global:Get-VICommand([string] $Name = "*") {
      get-command -pssnapin VMware.* -Name $Name
    }

    function global:Get-LicensingCommand([string] $Name = "*") {
      get-command -pssnapin VMware.VimAutomation.License -Name $Name
    }

    function global:Get-ImageBuilderCommand([string] $Name = "*") {
      get-command -pssnapin VMware.ImageBuilder -Name $Name
    }

    function global:Get-AutoDeployCommand([string] $Name = "*") {
      get-command -pssnapin VMware.DeployAutomation -Name $Name
    }

    # Tab Expansion for parameters of enum types.
    # This functionality requires powershell 2.0
    # Note: Make sure to surround Get-PSVersion with parentheses to force value comparison
    if((Get-PSVersion) -ge "2.0"){

        #modify the tab expansion function to support enum parameter expansion
        $global:originalTabExpansionFunction = $function:TabExpansion

        function global:TabExpansion {
           param($line, $lastWord)

           $originalResult = & $global:originalTabExpansionFunction $line $lastWord

           if ($originalResult) {
              return $originalResult
           }
           #ignore parsing errors. if there are errors in the syntax, try anyway
           $tokens = [System.Management.Automation.PSParser]::Tokenize($line, [ref] $null)

           if ($tokens)
           {
               $lastToken = $tokens[$tokens.count - 1]

               $startsWith = ""

               # locate the last parameter token, which value is to be expanded
               switch($lastToken.Type){
                   'CommandParameter' {
                        #... -Parameter<space>

                        $paramToken = $lastToken
                   }
                   'CommandArgument' {
                        #if the last token is argument, that can be a partially spelled value
                        if($lastWord){
                            #... -Parameter Argument  <<< partially spelled argument, $lastWord == Argument
                            #... -Parameter Argument Argument

                            $startsWith = $lastWord

                            $prevToken = $tokens[$tokens.count - 2]
                            #if the argument is not preceeded by a paramter, then it is a value for a positional parameter.
                            if ($prevToken.Type -eq 'CommandParameter') {
                                $paramToken = $prevToken
                            }
                        }
                        #else handles "... -Parameter Argument<space>" and "... -Parameter Argument Argument<space>" >>> which means the argument is entirely spelled
                   }
               }

               # if a parameter is found for the argument that is tab-expanded
               if ($paramToken) {
                   #locates the 'command' token, that this parameter belongs to
                   [int]$groupLevel = 0
                   for($i=$tokens.Count-1; $i -ge 0; $i--) {
                       $currentToken = $tokens[$i]
                       if ( ($currentToken.Type -eq 'Command') -and ($groupLevel -eq 0) ) {
                          $cmdletToken = $currentToken
                          break;
                       }

                       if ($currentToken.Type -eq 'GroupEnd') {
                          $groupLevel += 1
                       }
                       if ($currentToken.Type -eq 'GroupStart') {
                          $groupLevel -= 1
                       }
                   }

                   if ($cmdletToken) {
                       # getting command object
                       $cmdlet = Get-Command $cmdletToken.Content
                       # gettint parameter information
                       $parameter = $cmdlet.Parameters[$paramToken.Content.Replace('-','')]

                       # getting the data type of the parameter
                       $parameterType = $parameter.ParameterType

                       if ($parameterType.IsEnum) {
                          # if the type is Enum then the values are the enum values
                          $values = [System.Enum]::GetValues($parameterType)
                       } elseif($parameterType.IsArray) {
                          $elementType = $parameterType.GetElementType()

                          if($elementType.IsEnum) {
                            # if the type is an array of Enum then values are the enum values
                            $values = [System.Enum]::GetValues($elementType)
                          }
                       }

                       if($values) {
                          if ($startsWith) {
                              return ($values | where { $_ -like "${startsWith}*" })
                          } else {
                              return $values
                          }
                       }
                   }
               }
           }
        }
    }


    # Find and execute custom initialization file
    $existsCustomInitScript = Test-Path $CustomInitScript
    if($existsCustomInitScript) {
       & $CustomInitScript
    }

    [void][Reflection.Assembly]::LoadWithPartialName("VMware.Vim")

    function global:New-DatastoreDrive([string] $Name, $Datastore){
      begin {
        if ($Datastore) {
          Write-Output $Datastore | New-DatastoreDrive -Name $Name
        }
      }
      process {
        if ($_) {
          $ds = $_
          New-PSDrive -Name $Name -Root \ -PSProvider VimDatastore -Datastore $ds -Scope global
        }
      }
      end {
      }
    }

    function global:New-VIInventoryDrive([string] $Name, $Location){
      begin {
        if ($Location) {
          Write-Output $Location | New-VIInventoryDrive -Name $Name
        }
      }
      process {
        if ($_) {
          $location = $_
          New-PSDrive -Name $name -Root \ -PSProvider VimInventory -Location $location -Scope global
        }
      }
      end {
      }
    }

    function Get-VMHostWSManInstance {
      param (
      [Parameter(Mandatory=$TRUE,HelpMessage="VMHosts to probe")]
      [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]
      $VMHost,

      [Parameter(Mandatory=$TRUE,HelpMessage="Class Name")]
      [string]
      $class,

      [switch]
      $ignoreCertFailures,

      [System.Management.Automation.PSCredential]
      $credential=$null
      )

      $omcBase = "http://schema.omc-project.org/wbem/wscim/1/cim-schema/2/"
      $dmtfBase = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/"
      $vmwareBase = "http://schemas.vmware.com/wbem/wscim/1/cim-schema/2/"

      if ($ignoreCertFailures) {
        $option = New-WSManSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
      } else {
        $option = New-WSManSessionOption
      }
      foreach ($H in $VMHost) {
        if ($credential -eq $null) {
          $hView = $H | Get-View -property Value
          $ticket = $hView.AcquireCimServicesTicket()
          $password = convertto-securestring $ticket.SessionId -asplaintext -force
          $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ticket.SessionId, $password
        }
        $uri = "https`://" + $h.Name + "/wsman"
        if ($class -cmatch "^CIM") {
          $baseUrl = $dmtfBase
        } elseif ($class -cmatch "^OMC") {
          $baseUrl = $omcBase
        } elseif ($class -cmatch "^VMware") {
          $baseUrl = $vmwareBase
        } else {
          throw "Unrecognized class"
        }
        Get-WSManInstance -Authentication basic -ConnectionURI $uri -Credential $credential -Enumerate -Port 443 -UseSSL -SessionOption $option -ResourceURI "$baseUrl/$class"
      }
    }


    # Aliases
    set-alias Get-VIServer Connect-VIServer -Scope Global
    set-alias Get-VC Connect-VIServer -Scope Global
    set-alias Get-ESX Connect-VIServer -Scope Global
    set-alias Answer-VMQuestion Set-VMQuestion -Scope Global
    set-alias Get-PowerCLIDocumentation Get-PowerCLIHelp -Scope Global
    set-alias Get-VIToolkitVersion Get-PowerCLIVersion -Scope Global
    set-alias Get-VIToolkitConfiguration Get-PowerCLIConfiguration -Scope Global
    set-alias Set-VIToolkitConfiguration Set-PowerCLIConfiguration -Scope Global
    set-alias Export-VM Export-VApp -Scope Global

    # Uid utilities
    $global:UidUtil = [VMware.VimAutomation.ViCore.Cmdlets.Utilities.UidUtil]::Create()
    add-member -inputobject $global:UidUtil -membertype scriptmethod -name GetHelp -Value { Get-Help about_uid }
}


#########################################################################################
# VMWare Scripts                                                                        #
#########################################################################################

#
# Remove Orphaned Datastore VMDKs and Data
#
function Remove-OrphanedData {
  <#
  .SYNOPSIS   Remove orphaned folders and VMDK files
  .DESCRIPTION   The function searches orphaned folders and VMDK files
     on one or more datastores and reports its findings.
     Optionally the function removes  the orphaned folders   and VMDK files
  .NOTES   Author:  Luc Dekens
  .PARAMETER Datastore
     One or more datastores.
     The default is to investigate all shared VMFS datastores
  .PARAMETER Delete
     A switch that indicates if you want to remove the folders
     and VMDK files
  .EXAMPLE
     PS> Remove-OrphanedData -Datastore ds1
  .EXAMPLE
    PS> Get-Datastore ds* | Remove-OrphanedData
  .EXAMPLE
    PS> Remove-OrphanedData -Datastore $ds -Delete
  #>

  [CmdletBinding(SupportsShouldProcess=$true)]

  param(
  [parameter(Mandatory=$true,ValueFromPipeline=$true)]
  [PSObject[]]$Datastore,
  [switch]$Delete
  )

  begin{
    $fldList = @{}
    $hdList = @{}

    $fileMgr = Get-View FileManager
  }

  process{
    foreach($ds in $Datastore){
      if($ds.GetType().Name -eq "String"){
        $ds = Get-Datastore -Name $ds
      }
      if($ds.Type -eq "VMFS" -and $ds.ExtensionData.Summary.MultipleHostAccess){
        Get-VM -Datastore $ds | %{
          $_.Extensiondata.LayoutEx.File | where{"diskDescriptor","diskExtent" -contains $_.Type} | %{
            $fldList[$_.Name.Split('/')[0]] = $_.Name
            $hdList[$_.Name] = $_.Name
          }
        }
        Get-Template | where {$_.DatastoreIdList -contains $ds.Id} | %{
          $_.Extensiondata.LayoutEx.File | where{"diskDescriptor","diskExtent" -contains $_.Type} | %{
            $fldList[$_.Name.Split('/')[0]] = $_.Name
            $hdList[$_.Name] = $_.Name
          }
        }

        $dc = $ds.Datacenter.Extensiondata

        $flags = New-Object VMware.Vim.FileQueryFlags
        $flags.FileSize = $true
        $flags.FileType = $true

        $disk = New-Object VMware.Vim.VmDiskFileQuery
        $disk.details = New-Object VMware.Vim.VmDiskFileQueryFlags
        $disk.details.capacityKb = $true
        $disk.details.diskExtents = $true
        $disk.details.diskType = $true
        $disk.details.thin = $true

        $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
        $searchSpec.details = $flags
        $searchSpec.Query += $disk
        $searchSpec.sortFoldersFirst = $true

        $dsBrowser = Get-View $ds.ExtensionData.browser
        $rootPath = "[" + $ds.Name + "]"
        $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
        foreach($folder in $searchResult){
          if($fldList.ContainsKey($folder.FolderPath.TrimEnd('/'))){
            foreach ($file in $folder.File){
              if(!$hdList.ContainsKey($folder.FolderPath + $file.Path)){
                New-Object PSObject -Property @{
                  Folder = $folder.FolderPath
                  Name = $file.Path
                  Size = $file.FileSize
                  CapacityKB = $file.CapacityKb
                  Thin = $file.Thin
                  Extents = [string]::Join(',',($file.DiskExtents))
                }
                if($Delete){
                  If ($PSCmdlet.ShouldProcess(($folder.FolderPath + " " + $file.Path),"Remove VMDK")){
                    $dsBrowser.DeleteFile($folder.FolderPath + $file.Path)
                  }
                }
              }
            }
          }
          elseif($folder.File | where {"cos.vmdk","esxconsole.vmdk" -notcontains $_.Path}){
            $folder.File | %{
              New-Object PSObject -Property @{
                Folder = $folder.FolderPath
                Name = $_.Path
                Size = $_.FileSize
                CapacityKB = $_.CapacityKB
                Thin = $_.Thin
                Extents = [String]::Join(',',($_.DiskExtents))
              }
            }
            if($Delete){
              if($folder.FolderPath -eq $rootPath){
                $folder.File | %{
                  If ($PSCmdlet.ShouldProcess(($folder.FolderPath + " " + $_.Path),"Remove VMDK")){
                    $dsBrowser.DeleteFile($folder.FolderPath + $_.Path)
                  }
                }
              }
              else{
                If ($PSCmdlet.ShouldProcess($folder.FolderPath,"Remove Folder")){
                  $fileMgr.DeleteDatastoreFile($folder.FolderPath,$dc.MoRef)
                }
              }
            }
          }
        }
      }
    }
  }
}

function Get-VMEvents {
  <#
  .Synopsis

    Get events for an entity or for query all events.

  .Description

    This function returns events for entities. It's very similar to
  get-vievent cmdlet.Note that get-VMEvent can handle 1 vm at a time.
  You can not send array of vms in this version of the script.

  .Example

    Get-VMEvents 0All -types "VmCreatedEvent","VmDeployedEvent","VmClonedEvent"

    This will receive ALL events of types "VmCreatedEvent","VmDeployedEvent",
  "VmClonedEvent".

  .Example

    Get-VMEvents -name 'vm1' -types "VmCreatedEvent"

    Will ouput creation events for vm : 'vm1'. This was is faster than piping vms from
  get-vm result. There is no need to use get-vm to pass names to get-vmevents.
  Still, it is ok when you will do it, it will make it just a little bit slower ;)

  .Example

    Get-VMEvents -name 'vm1' -category 'warning'

    Will ouput all events for vm : 'vm1'. This was is faster than piping names from
  get-vm cmdlet. Category will make get-vmevent to search only defined category
  events.

  .Example

    get-vm 'vm1' | Get-VMEvents -types "VmCreatedEvent","VmMacAssignedEvent"

    Will display events from vm1 which will be regarding creation events,
  and events when when/which mac address was assigned


  .Parameter VM

    This parameter is a single string representing vm name. It expects single vm name that
  exists in virtual center. At this moment in early script version it will handle only a case
  where there is 1 instance of vm of selected name. In future it will handle multiple as
  well.

  .Parameter types

    If none specified it will return all events. If specified will return
  only events with selected types. For example : "VmCreatedEvent",
  "VmDeployedEvent", "VmMacAssignedEvent" "VmClonedEvent" , etc...

  .Parameter category

    Possible categories are : warning, info, error. Please use this parameter if you
  want to filter events.

  .Parameter All

    If you will set this parameter, as a result command will query all events from
  virtual center server regarding virtual machines.

  .Notes

    NAME:  VMEvents

    AUTHOR: Grzegorz Kulikowski

    LASTEDIT: 11/09/2012

  NOT WORKING ? #powercli @ irc.freenode.net

  .Link

    http://psvmware.wordpress.com
  #>

  param(
  [Parameter(ValueFromPipeline=$true)]
  [ValidatenotNullOrEmpty()]
  $VM,
  [String[]]$types,
  [string]$category,
  [switch]$All
  )
      $si=get-view ServiceInstance
      $em= get-view $si.Content.EventManager
      $EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
    $EventFilterSpec.Type = $types
    if($category){
    $EventFilterSpec.Category = $category
    }

    if ($VM){
    $EventFilterSpec.Entity = New-Object VMware.Vim.EventFilterSpecByEntity
    switch ($VM) {
    {$_ -is [VMware.Vim.VirtualMachine]} {$VMmoref=$vm.moref}
    {$_ -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]}{$VMmoref=$vm.Extensiondata.moref}
    default {$vmmoref=(get-view -ViewType virtualmachine -Filter @{'name'=$VM}).moref }
    }
    $EventFilterSpec.Entity.Entity = $vmmoref
          $em.QueryEvents($EventFilterSpec)
    }
    if ($All) {
    $em.QueryEvents($EventFilterSpec)
    }
}

function Get-VMCreationDate {
  <#
  .Synopsis
  Gets where possible vm creation date.

  .Description
  This function will return object with information about  creation time, method, month,
  creator for particular vm.
  VMname         : SomeVM12
  CreatedTime    : 8/10/2012 11:48:18 AM
  CreatedMonth   : August
  CreationMethod : Cloned
  Creator         : office\greg

  This function will display NoEvent value in properties in case when your VC does no
  longer have information about those particular events, or your vm events no longer have
  entries about being created. If your VC database has longer retension date it is more possible
  that you will find this event.

  .Example
  Get-VMCreationdate -VMnames "my_vm1","My_otherVM"

  This will return objects that contain creation date information for vms with names
  myvm1 and myvm2

  .Example
  Get-VM -Location 'Cluster1' |Get-VMCreationdate

  This will return objects that contain creation date information for vms that are
  located in Cluster1

  .Example
  Get-view -viewtype virtualmachine -SearchRoot (get-datacenter 'mydc').id|Get-VMCreationDate

  This will return objects that contain creation date information for vms that are
  located in datacenter container 'mydc'. If you are using this function within existing loop where you
  have vms from get-view cmdlet, you can pass them via pipe or as VMnames parameter.

  .Example
  $report=get-cluster 'cl-01'|Get-VMCreationdate
  $report | export-csv c:\myreport.csv
  Will store all reported creationtimes object in $report array variable and export report to csv file.
  You can also filter the report before writing it to csv file using select
  $report | Where-Object {$_.CreatedMonth -eq "October"} | Select VMName,CreatedMonth
  So that you will see only vms that were created in October.

  .Example
  get-vmcreationdate -VMnames "my_vm1",testvm55
  WARNING: my_vm1 could not be found, typo?
  VMname         : testvm55
  CreatedTime    : 10/5/2012 2:24:03 PM
  CreatedMonth   : October
  CreationMethod : NewVM
  Creator        : home\greg
  In case when you privided vm that does not exists in yor infrastructure, a warning will be displayed.
  You can still store the whole report in $report variable, but it will not include any information about
  missing vm creation dates. A warning will be still displayed only for your information that there was
  probably a typo in the vm name.

  .Parameter VMnames
  This parameter should contain virtual machine objects or strings that represents vm
  names. It is possible to feed this function wiith VM objects that come from get-vm or
  from get-view.

  .Notes
    NAME:  Get-VMCreationdate
    AUTHOR: Grzegorz Kulikowski
    LASTEDIT: 27/11/2012
    NOT WORKING ? #powercli @ irc.freenode.net

  .Link
    http://psvmware.wordpress.com

 #>

  param(
  [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [Object[]]$VMnames
  )

  process {
    foreach ($vm in $VMnames){
      $ReportedVM = ""|Select VMname,CreatedTime,CreatedMonth,CreationMethod,Creator
      if ($CollectedEvent=$vm|Get-VMEvents -types 'VmBeingDeployedEvent','VmRegisteredEvent','VmClonedEvent','VmBeingCreatedEvent' -ErrorAction SilentlyContinue){
        if($CollectedEvent.gettype().isArray){$CollectedEvent=$CollectedEvent|?{$_ -is [vmware.vim.VmRegisteredEvent]}}

        $CollectedEventType=$CollectedEvent.gettype().name
        $CollectedEventMonth = "{0:MMMM}" -f $CollectedEvent.CreatedTime
        $CollectedEventCreationDate=$CollectedEvent.CreatedTime
        $CollectedEventCreator=$CollectedEvent.Username

        switch ($CollectedEventType){
          'VmClonedEvent' {$CreationMethod = 'Cloned'}
          'VmRegisteredEvent' {$CreationMethod = 'RegisteredFromVMX'}
          'VmBeingDeployedEvent' {$CreationMethod = 'VmFromTemplate'}
          'VmBeingCreatedEvent'  {$CreationMethod = 'NewVM'}
          default {$CreationMethod='Error'}
        }

        $ReportedVM.VMname=$CollectedEvent.vm.Name
        $ReportedVM.CreatedTime=$CollectedEventCreationDate
        $ReportedVM.CreatedMonth=$CollectedEventMonth
        $ReportedVM.CreationMethod=$CreationMethod
        $ReportedVM.Creator=$CollectedEventCreator

      }else {
        if ($?) {
          if($vm -is [VMware.Vim.VirtualMachine]){$ReportedVM.VMname=$vm.name} else {$ReportedVM.VMname=$vm.ToString()}
          $ReportedVM.CreatedTime = 'NoEvent'
          $ReportedVM.CreatedMonth = 'NoEvent'
          $ReportedVM.CreationMethod = 'NoEvent'
          $ReportedVM.Creator = 'NoEvent'

        } else {
          $ReportedVM = $null
          Write-Warning "$VM could not be found, typo?"
        }
      }
      $ReportedVM
    }
  }
}

function Transfer-Alarm {
  <#
  .Synopsis
  This function is for copying Alarms from one vCenter instance to another.

  .Parameter AlarmName
  The name or names of the alarms to be tranfered/copied to the new vCenter.

  .Parameter Server
  The vcenter server from which the alarms will be copied

  .Parameter NewCluster
  The folder location where the alarms will be copied. By default it will copy them to the root of the vCenter instance.

  .Example
  Transfer-Alarm -alarmname "vNoob*" -olderserver "oldvcenter.vnoob.local" -newserver "newvcenter.vnoob.local"

  Will copy alarms that begin with the name vNoob from oldvcenter.vnoob.local to newvcenter.vnoob.local
  .Link

  .Notes
  Author:     Gonzalo Peci <gonzalo.peci@paymark.co.nz>

  Date:       2013-6-4

  Revision:   1.1
  #>

  param($Alarmnames, $Server, $NewCluster)

  function get_counterid([VMware.Vim.PerfCounterInfo] $perfcounterinfo, $availableperfcounters){
    # This is needed to 'translate' metrics between vcenter servers.
    # Alarms definiton are based on performance counter Ids.
    # But performance counter IDs may differ bteween vcenter servers.
    # Function takes two parameters. First one is a Vmware.Vim.Perfcounterinfo object representing the performance counter used for the original alarm expression
    # 2nd param is an array containing all perfcounters in the destination vcenter
    # Function returns the id of the perfcounter in the des vcenter that matches the perfcounter in the src vcenter
    $found = $false
    $cid = -1
    $i = 0
    while (($found -eq $false) -and ($i -lt $availableperfcounters.count ))
    {
      if(
          ($availableperfcounters[$i].NameInfo.Key -eq $perfcounterinfo.Nameinfo.Key) -and
          ($availableperfcounters[$i].GroupInfo.Key -eq $perfcounterinfo.Groupinfo.Key) -and
          ($availableperfcounters[$i].UnitInfo.Key -eq $perfcounterinfo.UnitInfo.Key) -and
          ($availableperfcounters[$i].RollupType -eq $perfcounterinfo.RollupType)
        )
      {
        $found = $true
        $cid = $availableperfcounters[$i].Key
      }
      $i++
    }
    $cid
  }

  # do you want to modify existing alarms or just import new ones?
  $mod=$False
  # Note the script will NOT delete any alarms in the dest vcenter, even if they do not exist in the src vcenter

  Set-Variable -Name alarmLength -Value 80 -Option "constant" -erroraction silentlycontinue

  ###
  #Get started
  ####
  #connect to Server
  $vc1 = $Server
  $vc1conn = connect-viserver $vc1

  $to=Get-Datacenter $NewCluster | Get-View

  #get the inventory root folder
  $vc1root=(Get-View serviceinstance).content.rootFolder

  # get the alarm manager
  $vc1alMgr=Get-View (Get-View serviceinstance -server $vc1).content.alarmManager

  # get the alarm view
  $vc1alarms=Get-View $vc1alMgr.GetAlarm($vc1root)

  #get the performance manager (needed for metrics alarms)
  $vc1perfMgr=Get-View (Get-View serviceinstance -server $vc1).Content.PerfManager

  $myalarms = New-Object system.Collections.arraylist
  $alarmmetrics = @{}

  $vc1alarms | ForEach-Object {
    # We don't want to copy all alarms , just the ones starting with "MY" for demonstartion purposes
    # Replace the regex with something suitable for your environment
    # If you want to copy everything just replace the next line with 'if ( $true )'
    if( $_.Info.Name -match $Alarmnames ){
      $alarm = $_
      $myalarms.add($_)
      # We need to check for MetricAlarmExpressions.
      # It seems that Alarms containing MetricAlarmExpression will always have either an OrAlarmExpression or an AndAlarmExpression, even if tehy just have a single trigger
      # But unfortunately we cannot assume that every alarm will have one of those. It looks like Event alarms sometimes only have a singleton AlarmExpression. Phew.
      if (($_.Info.Expression.GetType().FullName -eq "VMware.Vim.OrAlarmExpression") -or ($_.Info.Expression.GetType().FullName -eq "VMware.Vim.AndAlarmExpression"))
      {
        # We need to determine all metric alarm (sub-)expression. We need to save the metrics into an array for future use
        # First we determine how many triggers (expressions) the alarm is based on
        $numexps = $_.Info.Expression.Expression.Count
        # Then we define an array to hold the perfcounters for that alarm
        $thisperfcounters = New-Object Vmware.Vim.PerfCounterInfo[] $numexps
        # Then we retrieve all counters  for those triggers , if they are metrics (not StateAlarmexpressions)
        for ($i=0; $i -lt $numexps; $i++){
          if ($_.Info.Expression.Expression[$i].getType().FullName -eq "VMware.Vim.MetricAlarmExpression"){
            # The alarm expression only contains a  numeric counter id.
            # We need to get the complete counter semantic, so we can look up the appropriate counter id in the destination vcenter
            $thisperfcounters[$i]=$vc1perfmgr.QueryPerfCounter($_.Info.Expression.Expression[$i].Metric.Counterid)[0]
          }
        }

        # we now save the complete perfcounters corresponding to the metrics IDs .
        $alarmmetrics[$_.Info.Key] = New-Object Vmware.Vim.PerfCounterInfo[] $numexps
        $alarmmetrics[$_.Info.Key] = $thisperfcounters
      }
    }
  }

  # We disconnect from the src vc...
  Disconnect-VIServer $vc1
  # ... and connect to the dest vc
  $vc2 = $Server
  $vc2conn = connect-viserver $vc2

  #get the inventory root folder
  $vc2root=(get-view serviceinstance).content.rootFolder

  # get the alarm manager
  $vc2alMgr=get-view (get-view serviceinstance).content.alarmManager
  $vc2alarms = get-view $vc2alMgr.GetAlarm($vc1root)

  # get the performance manager
  $vc2perfMgr = Get-View (get-view serviceinstance -server $vc2).Content.PerfManager
  #... and the available performance counters
  $vc2counters = $vc2perfMgr.PerfCounter

  $importedalarms = $myalarms

  foreach ($importedAlarm in $importedalarms) {
    $create=$True
    # if we didn't find an existing alarm with the same name then let's create it
    if ($create) {
      $alSpec = new-object VMware.Vim.AlarmSpec
      $alSpec.Name = $importedAlarm.Info.name
      $alSpec.Action = $importedAlarm.Info.Action
      $numactions = $importedAlarm.Info.Action.Action.Count

      if ($numactions -gt 0){
        $alSpec.Action = New-Object vmware.vim.GroupAlarmAction
        $alSpec.Action.Action = new-object VMware.Vim.AlarmTriggeringAction[] $numactions

        # we need to copy every alarm action
        for ($i=0; $i -lt $numactions; $i++){
          $alSpec.Action.Action[$i] = New-Object VMware.Vim.AlarmTriggeringAction
          $alSpec.Action.Action[$i].Action = New-Object $importedAlarm.Info.Action.Action[$i].Action.GetType().Fullname
          $alSpec.Action.Action[$i].Action = $importedAlarm.Info.Action.Action[$i].Action
          $tspecs = $importedAlarm.Info.Action.Action[$i].TransitionSpecs.Count

          if ($tspecs -gt 0){
            $alSpec.Action.Action[$i].TransitionSpecs = New-Object VMware.Vim.AlarmTriggeringActionTransitionSpec[] $tspecs

            for ($j = 0 ; $j -lt $tspecs ; $j++ ){
              $alSpec.Action.Action[$i].TransitionSpecs[$j] = New-Object VMware.Vim.AlarmTriggeringActionTransitionSpec
              $alSpec.Action.Action[$i].TransitionSpecs[$j] = $importedAlarm.Info.Action.Action[$i].TransitionSpecs[$j]
            }
          }
          $alSpec.Action.Action[$i].Green2yellow = $importedAlarm.Info.Action.Action[$i].Green2yellow
          $alSpec.Action.Action[$i].Red2yellow = $importedAlarm.Info.Action.Action[$i].Red2yellow
          $alSpec.Action.Action[$i].Yellow2red = $importedAlarm.Info.Action.Action[$i].Yellow2red
          $alSpec.Action.Action[$i].Yellow2green = $importedAlarm.Info.Action.Action[$i].Yellow2green
        }
      }

      $alSpec.Enabled = $importedAlarm.Info.Enabled
      $alSpec.Description = $importedAlarm.Info.Description
      $alSpec.ActionFrequency = $importedAlarm.Info.ActionFrequency
      $alSpec.setting = New-Object VMware.Vim.AlarmSetting
      $alSpec.Setting = $importedAlarm.Info.Setting
      $alSpec.Expression = New-Object VMware.Vim.AlarmExpression
      $alSpec.Expression = $importedAlarm.Info.Expression

      if (($importedAlarm.Info.Expression.GetType().FullName -eq "VMware.Vim.OrAlarmExpression") -or ($importedAlarm.Info.Expression.GetType().FullName -eq "VMware.Vim.AndAlarmExpression") )
      {
        # We need to figure out the matching perfcounter id in the target vcenter for all MetricAlarmExpressions
        $numexps = $importedAlarm.Info.Expression.Expression.Count

        for ($i=0; $i -lt $numexps; $i++){
          if ($importedalarm.Info.Expression.Expression[$i].getType().FullName -eq "VMware.Vim.MetricAlarmExpression")
          {
            $vc1counterid = $alarmmetrics[$importedAlarm.Info.Key][$i]
            $alSpec.Expression.Expression[$i].Metric.Counterid = get_Counterid $vc1counterid $vc2counters
          }
          # get_counterid will return -1 if the counter does not exist in the dest vcenter
          # in that case the CreateAlarm action will fail
          # Hey, this is a sample script. Feel free to add a more graceful error handling
        }
      }
      $alSpec.Name = $alSpec.Name + " on " + $to.Name
      $vc2alMgr.CreateAlarm($to.MoRef,$alSpec)
    }
  }
  Disconnect-VIServer $vc2
}

function Kill-VM {
  <#
  .SYNOPSIS
  Kills a Virtual Machine.

  .DESCRIPTION
  Kills a virtual machine at the lowest level, use when Stop-VM fails.

  .PARAMETER  VM
  The Virtual Machine to Kill.

  .PARAMETER  KillType
  The type of kill operation to attempt. There are three
  types of VM kills that can be attempted:   [soft,
  hard, force]. Users should always attempt 'soft' kills
  first, which will give the VMX process a chance to
  shutdown cleanly (like kill or kill -SIGTERM). If that
  does not work move to 'hard' kills which will shutdown
  the process immediately (like kill -9 or kill
  -SIGKILL). 'force' should be used as a last resort
  attempt to kill the VM. If all three fail then a
  reboot is required.

  .EXAMPLE
  PS C:\> Kill-VM -VM (Get-VM VM1) -KillType soft

  .EXAMPLE
  PS C:\> Get-VM VM* | Kill-VM

  .EXAMPLE
  PS C:\> Get-VM VM* | Kill-VM -KillType hard
  #>
  param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    $VM, $KillType
  )
  PROCESS {
    if ($VM.PowerState -eq "PoweredOff") {
      Write-Host "$($VM.Name) is already Powered Off"
    } Else {
      $esxcli = Get-EsxCli -vmhost ($VM.Host)
      $WorldID = ($esxcli.vm.process.list() | Where { $_.DisplayName -eq $VM.Name}).WorldID
      if (-not $KillType) {
        $KillType = "soft"
      }
      $result = $esxcli.vm.process.kill($KillType, $WorldID)
      if ($result -eq "true"){
        Write-Host "$($VM.Name) killed via a $KillType kill"
      } Else {
        $result
      }
    }
  }
}