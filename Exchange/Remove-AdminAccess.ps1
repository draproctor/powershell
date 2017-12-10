function Remove-AdminAccess {
  [CmdletBinding()]
  [Alias('raa')]
  param(
    [String]$Identity
  )

  $raaSplat = @{
    'AccessRights' = 'FullAccess'
    'Identity' = $Identity
    'User' = $env:username+'@domain.com'
    'InheritanceType' = 'All'
    'Confirm' = $False
  }

  Remove-MailboxPermission @raaSplat
}
