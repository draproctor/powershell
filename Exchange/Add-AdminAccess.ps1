# AAA - add admin access
function Add-AdminAccess {
  [Alias('aaa')]
  param(
    [String]$Identity
  )

  $aaaSplat = @{
    'Identity' = $Identity
    'AccessRights' = 'FullAccess'
    'User' = $env:username + '@domain.com'
    'InheritanceType' = 'All'
    'AutoMapping' = $False
  }

  Add-MailboxPermission @aaaSplat
}
