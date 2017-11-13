<#
This is a function for setting seasonal wallpapers.

The idea is that a user collects wallpapers for each season. Running The
script once will create four folders in ~/Pictures that the appropriate
seasonal wallpaper can be placed in.

The script then determines the season, picks the appropriate folder, and
then pictures a random picture in that folder to be the new background.
#>

Import-Module Microsoft.PowerShell.Management

function Get-Season {
  [CmdletBinding()]
  # Fetch the current month.
  $date = Get-Date -Format MM
  # List of months by number for each season.
  $spring = @(3, 4, 5)
  $summer = @(6, 7, 8)
  $fall = @(9, 10, 11)
  $winter = @(12, 1 ,2)

  # Return the season.
  switch ($date) {
    {$date -in $spring} {return 'Spring'}
    {$date -in $summer} {return 'Summer'}
    {$date -in $fall} {return 'Fall'}
    {$date -in $winter} {return 'Winter'}
    default {exit}
  }
}

function New-WallpaperFolder {
  [CmdletBinding()]
  $picPath = "C:$env:homepath\Pictures"
  $gciSplat = @{
    Path = $picPath
    Directory = $true
  }
  $seasonNames = @(
    'Spring',
    'Summer',
    'Fall',
    'Winter'
  )
  $picDir = Get-ChildItem @gciSplat
  if ($picDir.Name -notcontains $seasonNames) {
    # If a season folder doesn't exist, create it.
    foreach ($s in $seasonNames) {
      $path = "$picPath\$s"
      $existenceCheck = Test-Path -Path $path
      if ($existenceCheck -eq $false) {
        try {
          $niSplat = @{
            Path = $path
            ItemType = 'Directory'
            Name = $s
          }
          New-Item @niSplat
        }
        catch {
          throw $_.Exception
        }
      }
      else {
        Write-Output "$s folder already exists."
      }
    }
  }
}

function Get-RandomWallpaper {
  [CmdletBinding()]
  # Declaring vars.
  $path = "C:\$env:homepath\Pictures"
  $seasonNames = @(
    'Spring',
    'Summer',
    'Fall',
    'Winter'
  )
  $wpDir = (Get-ChildItem -Path $path).where{$_.Name -in $seasonNames}
  # Changing $path to the appropriate season directory.
  $season = Get-Season
  $path = ($wpDir.where{$_.Name -eq $season}).FullName
  $randomWallpaper = Get-ChildItem -Path $path | Get-Random
  return $randomWallpaper.FullName
}

function Set-Wallpaper {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,ValueFromPipeline)]
    [string]$Path
  )

  # Setting the registry key for the wallpaper.
  # Takes effect at next logon.
  $setItemPropertySplat = @{
    Path = 'HKCU:\Control Panel\Desktop\'
    Name = 'WallPaper'
    Value = $Path
  }

  Set-ItemProperty @setItemPropertySplat
}

New-WallpaperFolder
Get-RandomWallpaper | Set-Wallpaper
