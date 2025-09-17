<#


    .SYNOPSIS
    Compares the group membership for the 2 specified users.
    .DESCRIPTION
    Compares the group membership for the 2 specified users.

#>

Param(
    [parameter(Mandatory=$True,
        ValueFromPipeline=$False,
        ValueFromPipelineByPropertyName=$False,
        HelpMessage="The first user to compare.")]
    [string] $UserOne,
    [parameter(Mandatory=$True,
        ValueFromPipeline=$False,
        ValueFromPipelinebyPropertyName=$False,
        HelpMessage="The second user to compare")]
    [string] $UserTwo
)

If (Get-Module -ListAvailable -Name 'Microsoft.Entra') {
    Write-Host "Microsoft.Entra module installed" -ForegroundColor Green
} else {
    Write-Host "Microsoft.Entra module must be installed prior to running this script." -ForegroundColor Red
    Exit
}

Connect-Entra -Scopes 'User.Read.All' -NoWelcome

$userOneGuids = Get-EntraUserMembership -UserId $UserOne | Select-Object 'Id'
$count1 = ($userOneGuids | Measure-Object).Count
Write-Host "$UserOne has $count1 group memberships."

$userTwoGuids = Get-EntraUserMembership -UserId $UserTwo | Select-Object 'Id'
$count2 = ($userTwoGuids | Measure-Object).Count
Write-Host "$UserTwo has  $count2 group memberships."

Compare-Object -ReferenceObject $userOneGuids -DifferenceObject $userTwoGuids -IncludeEqual
