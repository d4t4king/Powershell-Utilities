<#

    .SYNOPSIS
    Gets the OS version from the kernel32.dll.

#>

function Get-OSVersion
{
    $signature = @"
    [DllImport("kernel32.dll")]
    public static extern uint GetVersion();
"@
Add-Type -MemberDefinition $signature -Name "Win32OSVersion" -Namespace Win32Funtions -PassThru
}

$os = [System.BitConverter]::GetBytes((Get-OSVersion)::GetVersion())
$majorVersion = $os[0]
$minorVersion = $os[1]
$build = [byte]$os[2],[byte]$os[3]
$buildNumber = [System.BitConverter]::ToInt16($build,0)

$osversion = [environment]::OSVersion

"Version is {0}.{1} build {2}" -F $majorVersion,$minorVersion,$buildNumber
Write-Output "Compare to (environment): $osversion"
"OR compare to (WMI): {0}" -F (Get-CimInstance Win32_OperatingSystem).Version