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

[CmdletBinding(DefaultParameterSetName = "Domain")]
Param(
    [parameter(Mandatory = $True, 
        HelpMessage = "The username to look up.",
        ParameterSetName = "Domain")]
    [parameter(Mandatory = $True,
        ParameterSetName = "Local")]
    [parameter(Mandatory = $True,
        ParameterSetName = "Entra")]
    [String] $Username,

    [parameter(Mandatory=$False, 
        HelpMessage = "The domain of the username.  Defaults to `"TESTDOMAIN`".",
        ParameterSetName = "Domain")]
    [string] $UserDomain = "TESTDOMAIN",
    
    [parameter(Mandatory=$False, 
        HelpMessage="Use this switch for local users (like BUILT-IN/Administrator).",
        ParameterSetName = "Local")]
    [switch] $Local = $false,

    [parameter(Mandatory=$False, 
        ParameterSetName = "Entra",
        HelpMessage = "Use this switch to force a connection to Microsoft Graph (if needed) to collect data from EntraID, instead of an on-premises directory service.")]
    [switch] $Entra = $false
)

function Test-HasMgContext {
    # Define the required scopes
    $RequiredScopes = "User.Read.All", "Group.Read.All", "GroupMember.Read.All"

    # Check if a connection exists and has the necessary scopes
    try {

        $Context = Get-MgContext -ErrorAction Stop
        $CurrentScopes = $Context.Scopes

        # Check if all required scopes are present in the current session
        $HasRequiredScopes = $RequiredScopes | ForEach-Object { $_ } | Where-Object { $CurrentScopes -contains $_ }

        if ($null -eq $Context) {
            #Write-Host "Not connected to Microsoft Graph. Connecting now..."
            #Connect-MgGraph -Scopes $RequiredScopes -NoWelcome
            Write-Host "Not connected to Microsoft Graph."
        } elseif ($HasRequiredScopes.Count -ne $RequiredScopes.Count) {
            #Write-Host "Connected, but missing required scopes. Reconnecting with full scopes..."
            #Connect-MgGraph -Scopes $RequiredScopes -NoWelcome
            # Make this a true "Test" (no actual "doing")
            Write-Host "Connected, but missing required scopes."
        } else {
            Write-Verbose "Already connected to Microsoft Graph with the necessary scopes."
        }
    } catch {
        # If Get-MgContext fails (e.g., no connection), connect
        #Write-Host "An error occurred while checking connection (possibly not connected). Connecting now..."
        #Connect-MgGraph -Scopes $RequiredScopes -NoWelcome
        $errorObj = New-Object System.FormatException("There was an unknown error.")
        Throw $errorObj
    }

    # Verify the final connection
    Get-MgContext | Format-List

}

$objUser = ''

try {
    if ($Local) {
        $objUser = New-Object System.Security.Principal.NTAccount($Username)
    } else {
        $objUser = New-Object System.Security.Principal.NTAccount($userDomain, $Username)
        # a7d8bc73-121d-4355-bab4-8cbf34530232
        if ($ObjectId -match "[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}") {
            if (-not (Test-HasMgContext)) {
                Connect-MgGraph -Scopes 'User.Read.All','GroupMember.Read.All','Group.Read.All' -NoWelcome
            }
            $User = Get-MgUser -UserId $ObjectId | Select-Object UserPrincipalName, DisplayName, Surname, GivenName, ID
            $User
        } else {
            $errorObj = New-Object System.FormatException("ObjectID ($ObjectId) not recognized as a user object ID.")
            Throw $errorObj
        }
    }
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    $strSID.Value
} 
catch [System.Management.Automation.MethodInvocationException] {
    Connect-Entra -Scopes 'User.Read.All'
    $user = Get-EntraUser -Filter "givenName eq '$Username'"
    $user.id
}

