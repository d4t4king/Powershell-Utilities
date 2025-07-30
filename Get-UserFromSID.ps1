<#
    .SYNOPSIS
    Gets the username from the SID

    .DESCRIPTION
    Get the username from the SID

    .PARAMETERS
    SID - The SID to lookup for the username

    .INPUTS

    .OUTPUTS

    .EXAMPLE

#>

Param(
    [parameter(Mandatory = $True,
        HelpMessage = "The SID of the user to lookup.",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String] $SID
)

if ($SID -match "S-1-5-\d{2}-\d{8}-\d{10}-\d{10}-\d{8,10}") {
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
    $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
    $objUser.Value
} else {
    $errorObj = New-Object System.FormatException("SID ($SID) not recognized as a user SID.  Maybe a group GUID?")
    Throw $errorObj
}
