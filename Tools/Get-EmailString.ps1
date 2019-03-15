function Get-EmailString {
  <#
  .SYNOPSIS
    Retrieve all instances of an email from any string.
  .DESCRIPTION
    Long description
  .EXAMPLE
    Get-EmailString retrieves all instances of an email in the given string. It
    automatically replaces the 'mailto:' string with whitespace so that the two
    emails are not confused. To get only unique emails, use the -Unique
    parameter.

    PS C:\> 'testing@foo.commailto:testing@foo.com' | Get-EmailString
    testing@foo.com
    testing@foo.com

    PS C:\> 'testing@foo.commailto:testing@foo.com' | Get-EmailString -Unique
    testing@foo.com
  .EXAMPLE
    Some cmdlets accept UPNs by property name and Get-EmailString can return
    PSCustomObjects with UserPrincipalName properties to enable pipeline
    support.

    PS C:\> 'John Smith jsmith@foo.bar; Jane Doe jdoe@foo.bar' |
      Get-EmailString -AsUserPrincipalName |
      Get-MsolUser
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    By default, Get-EmailString remove 'mailto:' from strings. To stop this
    behavior, set the -RemoteMailToString parameter to $false.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$InputString,
    [Parameter(Position = 1)]
    [switch]$AsUserPrincipalName,
    [bool]$RemoveMailToString = $true,
    [switch]$Unique
  )
  begin {
    # Create regex matching object.
    $regex = [regex]::new(
      '\w+([-+.'']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*',
      [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
  }
  process {
    # Process matches.
    if ($RemoveMailToString) {
      $InputString = $InputString -replace 'mailto(:)?', ' '
    }
    $results = $regex.Matches($InputString).Value
    if ($Unique.IsPresent) {
      # Emails are not case sensitive, so we downcase to remove dupes.
      $results = $results.ToLower() | Select-Object -Unique
    }

    foreach ($r in $results) {
      # Return UPN object for cmdlets down the pipeline, else return a string.
      if ($AsUserPrincipalName.IsPresent) {
        [PSCustomObject]@{UserPrincipalName = $r.ToString()}
      }
      else {
        $r.ToString()
      }
    }
  }
}
