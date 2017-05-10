Convert first and last names to AD names.
# KAMBER IMPROVED THIS.
Function Get-ADName {
  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipeline,Mandatory=$true)]
    [System.String[]]$SearchObject,
    [Switch]$UsernameOnly
  )

  process {
    $getaduserSplat = @{
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
