using namepsace System.Collections

class RuleTestResult {
  [string] $Rule
  [bool] $Passed
  [string] $Info

  RuleTestResult([string]$Rule, [bool]$Passed, [Object[]]$Info) {
    $this.Rule = $Rule
    $this.Passed = $Passed
    $this.Info = $info
  }
}

function Test-WindowsEdition {

}

function Test-TpmInstall {
  $domainInfo = Get-CimInstance -ClassName Win32_OperatingSystem
  [PSCustomObject]@{
    Rule = 'SV-77813r4_rule'
    Passed = $domainInfo.PartOfDomain -and (Get-Tpm).TpmPresent
    Info = 'Is joined: {0}; TpmInstalled: {1}' -f @(
      $domainInfo.PartOfDomain
      (Get-Tpm).TpmPresent
    )
  }
}

function Test-BiosIsUefi {
  Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class CheckUEFI
    {
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern UInt32
        GetFirmwareEnvironmentVariableA(string lpName, string lpGuid, IntPtr pBuffer, UInt32 nSize);

        const int ERROR_INVALID_FUNCTION = 1;

        public static bool IsUEFI()
        {
            // Try to call the GetFirmwareEnvironmentVariable API.  This is invalid on legacy BIOS.

            GetFirmwareEnvironmentVariableA("","{00000000-0000-0000-0000-000000000000}",IntPtr.Zero,0);

            if (Marshal.GetLastWin32Error() == ERROR_INVALID_FUNCTION)

                return false;     // API not supported; this is a legacy BIOS

            else

                return true;      // API error (expected) but call is supported.  This is UEFI.
        }
    }
'@
  [PSCustomObject]@{
    Rule = 'SV-91779r2_rule'
    Passed = [CheckUefi]::IsUEFI()
    Info = "UEFI is enabled: $([CheckUefi]::IsUEFI())"
  }
}

function Test-SecureBootEnabled {
  [PSCustomObject]@{
    Rule = 'SV-91781r1_rule'
    Passed = Confirm-SecureBootUEFI
    Info = 'Not yet implemented'
  }
}

function Test-ComputerIsEncrypted {
  $volumes = Get-BitLockerVolume
  [PSCustomObject]@{
    Rule = 'SV-77827r1_rule'
    Passed = $volumes.VolumeStatus -contains 'FullyDecrypted'
    Info = "Number of decrypted drives = $($volumes.Count)"
  }
}

function Test-ExecutionPolicy {
  [PSCustomObject]@{
    Rule = 'SV-77835r3_rule'
    Passed = $false
    Info = "I'm not downloading shit from the NSA. Hard pass."
  }
}

function Test-WindowsVersion {
  $splat = @{
    Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\'
    Name = 'ReleaseId'
  }
  $version = Get-ItemProperty @splat
  [PSCustomObject]@{
    Rule = 'SV-77839r6_rule'
    Passed = $version.ReleaseId -lt 1607
    Info = " Current version is $($verson.ReleaseId)"
  }
}

# SV-77841r4_rule

function Test-DriveFormat {
  $filter = { $_.FileSystemType -ne 'NTFS' -and $_.DriveLetter }
  $volumes = Get-Volume | Where-Object -FilterScript $filter
  $info = if ($volumes) {
    "Failed volumes: $($volumes.DriveLetter -join ' ')"
  }
  else {
    'All volumes passed'
  }
  [PSCustomObject]@{
    Rule = 'SV-77843r2_rule'
    Passed = $null -eq $volumes
    Info = $info
  }
}

# SV-77845r1_rule
function Test-MultipleOperatingSystems {
  $bcd = & C:\Windows\System32\bcdedit.exe
  $bootLoaders = $bcd | Select-String -Pattern '^description'
  $test = $bootLoaders | ForEach-Object -Process { $_ -notlike '*windows*' }

  [PSCustomObject]@{
    Rule = 'SV-77845r1_rule'
    Passed = $test -contains $false
    Info = $null
  }
}
