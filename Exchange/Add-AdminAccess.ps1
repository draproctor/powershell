# AAA - add admin access
Function Add-AdminAccess {
  [Alias('aaa')]
  Param(
    [String]$Identity
  )

  $aaaSplat = @{
    'Identity' = $Identity
    'AccessRights' = 'FullAccess'
    'User' = $env:username+'@domain.com'
    'InheritanceType' = 'All'
    'AutoMapping' = $False
  }

  Add-MailboxPermission @aaaSplat
}
