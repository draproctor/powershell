#Adding users to the resource bookinpolicy to a resource/room mailbox.
function Add-BookInPolicy {
  [CmdletBinding()]
  param(
    [String]$Room,
    [String[]]$User
  )

  $bookInPolicy = (Get-CalendarProcessing -Identity $Room).BookInPolicy
  $bookInPolicy += $User
  Set-CalendarProcessing -Identity $Room -BookInPolicy $bookInPolicy
  foreach ($u in $User){
    Write-Output "Added $u as a BookInPolicy delegate to ${Room}."
  }
}
