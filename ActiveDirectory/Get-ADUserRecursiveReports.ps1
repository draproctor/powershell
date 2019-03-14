function Get-ADUserRecursiveReports {
  <#
  .SYNOPSIS
    Pull a list of AD users that all ultimately report to a single manager. This
    is useful for getting org chart data.
  .DESCRIPTION
    Pull a list of AD users that all ultimately report to a single manager. This
    is useful for getting org chart data.
  .EXAMPLE
    PS C:\> Get-ADUserRecursiveReports -Identity jsmith
    Returns an array of Microsoft.ActiveDirectory.Management.ADAccount objects
    containing all users that are under jsmith's reporting tree.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object[]
  #>
  [CmdletBinding()]
  [OutputType('System.Object[]')]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
  )
  begin {
    if (!(Get-Module -Name ActiveDirectory)) {
      Write-Error -Message 'ActiveDirectory module not loaded. Exiting.'
    }
  }
  process {
    # If the manager can't be found, let's exit.
    $reportSplat = @{
      Identity = $Identity
      Properties = 'directReports'
      ErrorAction = 'Stop'
    }
    $topManager = Get-ADUser @reportSplat
    Write-Verbose -Message "Top level manager: $($topManager.SamAccountName)"
    if ($null -ne $topManager.directReports) {
      # We don't want to return disabled users.
      $enabledReports = $topManager.directReports |
        Get-ADUser |
        Where-Object {$_.Enabled}
      foreach ($report in $enabledReports) {
        Write-Verbose -Message "Checking additional reports for: $report"
        # Return the enabled report and then check for reports under them too.
        $report
        Get-ADUserRecursiveReports -Identity $report.DistinguishedName
      }
    }
    else {
      Write-Verbose -Message "No reports for $($topManager.SamAccountName)"
    }
  }
}

