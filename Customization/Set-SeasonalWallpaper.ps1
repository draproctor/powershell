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
  $spring = 3, 4, 5
  $summer = 6, 7, 8
  $fall = 9, 10, 11
  $winter = 12, 1 , 2

  # Return the season.
  switch ($date) {
    {$date -in $spring} {
      Write-Verbose -Message 'The season is spring.'
      return 'Spring'
    }
    {$date -in $summer} {
      Write-Verbose -Message 'The season is summer.'
      return 'Summer'
    }
    {$date -in $fall} {
      Write-Verbose -Message 'The season is fall.'
      return 'Fall'
    }
    {$date -in $winter} {
      Write-Verbose -Message 'The season is winter.'
      return 'Winter'
    }
    default {exit}
  }
}

function New-WallpaperFolder {
  [CmdletBinding()]
  
  # Declare variables
  $seasonNames = @(
    'Spring'
    'Summer'
    'Fall'
    'Winter'
  )

  # begin region EnvironmentSetup
  $joinPathSplat = @{
    Path      = $env:SystemDrive
    ChildPath = "$env:HOMEPATH\Pictures"
  }
  $picPath = Join-Path @joinPathSplat

  if (!(Test-Path $picPath)) {
    Write-Verbose -Message "$picPath missing, creating directory."
    $null = New-Item -Path $picPath -ItemType Directory
  }
  # end region EnvironmentSetup

  foreach ($name in $seasonNames) {
    if ((Test-Path -Path "$picPath\$name") -eq $false) {
      try {
        $niSplat = @{
          Path     = $path
          ItemType = 'Directory'
          Name     = $name
        }
        New-Item @niSplat
      }
      catch {
        $PSCmdlet.ThrowTerminatingError($_)
      }
    }
    else {
      Write-Verbose -Message "$picPath\$name already exists."
    }
  }
}

function Get-RandomWallpaper {
  [CmdletBinding()]
  # Declaring splat.
  $joinPathSplat = @{
    Path = $env:SystemDrive
    ChildPath = "$env:HOMEPATH\Pictures\$(Get-Season)"
  }

  $path = Join-Path @joinPathSplat
  $randomWallpaper = Get-ChildItem -Path $path | Get-Random
  return $randomWallpaper.FullName
}

function Set-Wallpaper {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Path
  )

  # Setting the registry key for the wallpaper.
  # Takes effect at next logon.
  $setItemPropertySplat = @{
    Path  = 'HKCU:\Control Panel\Desktop\'
    Name  = 'WallPaper'
    Value = $Path
  }

  Set-ItemProperty @setItemPropertySplat
}

New-WallpaperFolder
Get-RandomWallpaper | Set-Wallpaper
