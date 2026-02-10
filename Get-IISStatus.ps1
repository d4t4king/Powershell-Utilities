<#

    .SYNOPSIS
        Retrieves the status of IIS services on the local machine.

#>

[CmdletBinding()]
Param()

$iisServices = Get-Service -Name W3SVC,IISADMIN,WAS,NetTcpPortSharing -ErrorAction SilentlyContinue
foreach ($service in $iisServices) {
    foreach ($parentSvc in ($service.ServicesDependedOn | Sort-Object -Property Name)) {
        if ($parentSvc.Status -eq 'Stopped') {
            Write-Host "- $($parentSvc.Name): $($parentSvc.Status)" -ForegroundColor Red
        } else {
            Write-Host "- $($parentSvc.Name): $($parentSvc.Status)" -ForegroundColor Yellow
        }
    }
    if ($service.Status -eq 'Stopped') {
        Write-Host "  \_ $($service.Name): $($service.Status)" -ForegroundColor Red
    } else {
        Write-Host "  \_ $($service.Name): $($service.Status)" -ForegroundColor Green
    }
}

Import-Module WebAdministration #-ErrorAction SilentlyContinue
$websites = Get-Website
$websites
