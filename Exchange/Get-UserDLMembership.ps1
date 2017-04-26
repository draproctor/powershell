# KAMBER MADE THIS
# But I'm adding it to my repo anyway :P
Function Get-UserDLMembership {
  Param(
    [String]$User
  )

  forEach ($Member in $User) {
      Get-ADUser $Member -Property MemberOf |
      % {
            $_.MemberOf |
            Get-ADGroup |
            where { $_.GroupCategory -like "*stribution*" } |
            Select Name |
            Sort Name
        }
  }
}
