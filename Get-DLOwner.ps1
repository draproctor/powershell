# Get the MembershipJoinRestriction of a DL.
Function Get-DLOwner {
  Param (
    [Parameter(Mandatory=$true)]
    [String]$Identity
  )

  $pssession = Get-PSSession

  # Check to see if any kind of EMS is enabled. If not, Enable-EMS.
  If ($pssession.ConfigurationName -notcontains 'Microsoft.Exchange'){
    Write-Warning "EMS not enabled. Enabling EMS..."
    <enable exchange commands here>
  }
  <#
    Check to see if O365 has been enabled. If it has been, provide the
    means to disconnect and reconnect to on-prem EMS.
  #>
  Elseif ($pssession.ComputerName -contains "outlook.office365.com"){
    Write-Warning "Currently connected to O365."
    Write-Warning "Changes cannot be made to the DL on O365.`n"
    Write-Host "Would you like to switch to on-prem EMS? (y, yes)"
    $response = Read-Host
    $answers = @('y', 'yes')
    If ($response.ToLower() -in $answers){
      $pssession |
      ? {$_.ConfigurationName -eq 'Microsoft.Exchange'} |
      Remove-PSSession
      <enable exchange commands here>
    }
    Else {
      Write-Host 'No action requested. O365 still enabled.' -Foreground Yellow
    }
  }

  $DL = Get-DistributionGroup -Identity $Identity

  If ($DL.MemberJoinRestriction -eq 'Open'){
    Write-Host "This DL is open. No manager approval required."
  }
  Elseif ($DL.MemberJoinRestriction -eq 'Closed' -and
      $DL.ManagedBy.Count -eq 0){
    <#
    There are cases where a DL is closed but has no managers. This case is for
    catching those DLs in particular, so that the HD tech can add a manager or
    change the MemberJoinRestriction.
    #>
    Write-Host "The DL is closed but there are no managers."
    Write-Host "Please either change the DL to Open or add a manager."
  }
  Elseif ($DL.MemberJoinRestriction -eq 'Closed' -or
      $DL.MemberJoinRestriction -eq 'ApprovalRequired'){
    If ($DL.MemberDepartRestriction -eq 'Closed'){
      Write-Host "Manager approval required to remove any members. `r`n"
      Write-Host 'Manager approval for addition still required.'
    }
    Write-Host "The DL is closed. Here is a list of the managers:"
    ForEach ($owner in $DL.ManagedBy){
      $user = $owner.split('/')[-1]
      Get-ADUser -Filter {(DisplayName -eq $user) -or
        (SamAccountName -eq $user) -or
        (Name -eq $user)} -Properties * |
      Select DisplayName,UserPrincipalName
    }
  }
  Else {
    Write-Host "An unknown error has occured with getting the DL settings."
    Write-Host "Investigate the error and then try again."
  }
}
