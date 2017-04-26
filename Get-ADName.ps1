# Convert first and last names to AD names.
# KAMBER IMPROVED THIS.
Function Get-ADName {
  <#  
    .SYNOPSIS
    Fetches the AD names given the display name(s) of user(s).
    .PARAMETER SearchObject
    This is the displayname or other search term used to get the username.
    .PARAMETER UsernameOnly
    This is a switch for getting only usernames or not. By default, both
    displaynames and samaccountnames are displayed in a list.

    .EXAMPLE
    Get-ADName -SearchObject "Austin Proctor"
    Get-ADName "Austin Proctor" -UsernameOnly
    "Jane Doe","John Doe" | Get-ADName
    "Jane Doe","John Doe" | Get-ADName -UsernameOnly
  #>
  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipeline,Mandatory=$true)]
    [System.String[]]$SearchObject,
    [Switch]$UsernameOnly
  )

  process {
    $getasuderSplat = @{
      'Filter' = 'DisplayName -eq $User -or SamAccountName -eq $User'
      'Properties' = '*'
    }
    if ($UsernameOnly){
      ForEach ($User in $SearchObject){
        $ADAccount = Get-ADUser @getaduserSplat |
          Select SamAccountName -First 1
    	  If (!($ADAccount)){
    		  Write-Host "$User was not found. Check spelling." -Background Red
    	  }
        Else {
    		  $ADAccount
    	  }
      }
    }
    else {
      ForEach ($User in $SearchObject){
        $ADAccount = Get-ADUser @getaduserSplat |
          Select DisplayName,SamAccountName -First 1
    	  If (!($ADAccount)){
    		  Write-Host "$User was not found. Check spelling." -Background Red
    	  }
        Else {
    		  $ADAccount
    	  }
      }
    }
  }
}
