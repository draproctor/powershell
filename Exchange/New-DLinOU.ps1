function New-DLInOu {
  [CmdletBinding()]
  [Alias('newdl')]

  param(
    [Parameter(Mandatory=$true,Position=0)]
    [System.String]$Name,
    [Parameter(Mandatory=$true,Position=1)]
    [System.String]$Alias,
    [Parameter(Mandatory=$true,Position=2)]
    [System.String[]]$ManagedBy
  )

  $newDLSPlat = @{
    'Name' = $Name
    'Alias' = $Alias
    'OrganizationalUnit' = 'mydomain/distribution groups'
    'ManagedBy' = @($ManagedBy)
  }
  New-DistributionGroup @newDLSplat
}
