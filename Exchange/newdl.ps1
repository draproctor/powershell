Function newdl {
  [CmdletBinding()]

  Param(
    [Parameter(Mandatory=$true,Position=0)]
    [System.String]$Name,
    [Parameter(Mandatory=$true,Position=1)]
    [System.String]$Alias,
    [Parameter(Mandatory=$true,Position=2)]
    [System.String[]]$ManagedBy
  )

  process{
    $NewDLSPlat = @{
      'Name' = $Name
      'Alias' = $Alias
      'OrganizationalUnit' = 'mydomain/distribution groups'
      'ManagedBy' = @($ManagedBy)
    }

    New-DistributionGroup @NewDLSplat
  }
}
