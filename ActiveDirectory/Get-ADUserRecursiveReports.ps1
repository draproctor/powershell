function Get-ADUserRecursiveReports {
  [CmdletBinding()]
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

