Function New-FormattedMC {
  [CmdletBinding()]

  Param(
    [Parameter(ValueFromPipeline,Mandatory=$true)]
    $Email
  )
  process{
    $nmcSplat = @{
      'ExternaleMailAddress' = "SMTP:${Email}"
      'Name' = $Email.replace('@','AT')
      'Alias' = $Email.replace('@','AT')
      'FirstName' = $Email -replace "@.*"
      'OrganizationalUnit' = 'mydomain\mailcontacts'
    }
    ForEach ($address in $Email){
      New-MailContact @nmcSplat
    }
  }
}
