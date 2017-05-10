#Adding users to the resource bookinpolicy to a resource/room mailbox.
Function Add-BookInPolicy {
  # Declaring the parameters for the room and user aliases.
  Param(
  [String]$Room,
  [String]$User
  )
  # Get the current booking list, use the += operator to add a new user to the list.
  # Set BookInPolicy to new list.
  $BookingList = (Get-CalendarProcessing -Identity $Room).BookInPolicy;
  $BookingList += $User;
  Set-CalendarProcessing -Identity $Room -BookInPolicy $BookingList
  ForEach ($Mailbox in $User){
    Write-Host "Added $User as a BookInPolicy delegate to ${Room}."
  }
}
