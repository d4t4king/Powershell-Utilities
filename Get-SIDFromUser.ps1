<#
    .SYNOPSIS   
        Gets the SID for the designated user.

    .DESCRIPTION
        Gets the SID for the designated user.

    .PARAMETERS

    .INPUTS

    .OUTPUTS

    .EXAMPLE

#>

Param(
    [parameter(Mandatory = $True, 
        HelpMessage = "The username to look up.",
        ParameterSetName = "Domain")]
    [String] $Username,

    [parameter(Mandatory=$False, 
        HelpMessage = "The domain of the username.  Defaults to `"TESTDOMAIN`".",
        ParameterSetName = "Domain")]
    [string] $UserDomain = "TESTDOMAIN",
    
    [parameter(Mandatory=$False, 
        HelpMessage="Use this switch for local users (like BUILT-IN/Administrator).",
        ParameterSetName = "Local")]
    [switch] $Local
)
$objUser = ''

try {
    if ($Local) {
        $objUser = New-Object System.Security.Principal.NTAccount($Username)
    } else {
        $objUser = New-Object System.Security.Principal.NTAccount($userDomain, $Username)  
    }
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    $strSID.Value
} 
catch [MethodInvocationException] {
    Connect-Entra -Scopes 'User.Read.All'
    $user = Get-EntraUser -Filter "givenName eq '$Username'"
    $user.id
}

