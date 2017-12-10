# KAMBER MADE THIS
# But I'm adding it to my repo anyway :P
function Get-UserDLMembership {
  param(
    [string[]]$User
  )

  foreach ($u in $User) {
    Get-ADUser $u -Property MemberOf |
      Foreach-Object {
          $_.MemberOf |
          Get-ADGroup |
          Where-Object { $_.GroupCategory -like "*stribution*" } |
          Select Name |
          Sort Name
        }
  }
}
