<#

    .SYNOPSIS
        Retrieves the user information from Entra ID using the provided Object ID.
    
    .DESCRIPTION
        This script defines a function `Convert-ObjectId2User` that takes an Entra ID Object ID as input and retrieves the corresponding user information from Microsoft Graph. It checks for an active connection to Microsoft Graph and prompts for authentication if necessary.

    .PARAMETER ObjectId
        The Entra ID Object ID of the user to lookup. This should be a valid GUID format.
    
    .EXAMPLE
        Convert-ObjectId2User -ObjectId "a7d8bc73-121d-4355-bab4-8cbf34530232"
        This command will retrieve the user information for the specified Object ID.
#>

Param(
    [parameter(Mandatory = $true,
        HelpMessage = "The (Entra) object ID of the user to lookup.",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string] $ObjectId
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