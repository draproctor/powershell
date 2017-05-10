Function Remove-BookInPolicy {
  Param(
    [String]$User,
    [String]$Room
  )
  <#
    Because the .remove method only removes on object at a time, this function must
    be used in a ForEach loop to remove multiple users.
  #>
  $legacyUsername = (Get-Mailbox $User).LegacyExchangeDN
  $bookInList = (Get-CalendarProcessing -Identity $Room).BookInPolicy
  $bookInList.remove($legacyUsername)
  Set-CalendarProcessing -Identity $Room -BookInPolicy $bookInList
  Write-Host "Removed $User from the BookInPolicy list of $Room"
}
