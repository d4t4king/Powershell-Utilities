<#
    
    .SYNOPSIS
    Check the members of the admin group (for 2016 server upgrades)

    .DESCRIPTION
    Check the members of the admin group (for 2016 server upgrades)

#>

[CmdletBinding()]
Param (
    [parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string] $GroupName
)

# Need to make a check for this.  If ANY version is already installed, skip the install.
# Install-Module Microsoft.Graph -Scope CurrentUser
# # Or for the Entra module:
# Install-Module Microsoft.Entra -Scope CurrentUser

# Seems the max number of functions that can be loaded in powershell 5.x is 4096.  
# Check the version and set it to a higher limit.

function Install-ModuleIfNotInstalled {
    Param(
        [parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false)]
        [string] $moduleName
    )

    if (-not (Get-Module -Name $moduleName -ListAvailable)) {
        Write-Host "Module $moduleName not found.  Attempting to install from PSGallery...."

        # Check for admin rights if installing for all users
        # Impelement this checK?
        # If running with out admin, install with -Scope CurrentUser to avoid permission issues.
        try {
            Install-Module -Name $moduleName -Scope CurrentUser -Force -Verbose
            Write-Host "Successfully installed $moduleName."
        } catch {
            Write-Warning "Failed to install $moduleName in CurrentUser scope.  You may need Administrator priviledges to install it globally."
            Write-Warning $_.Exception.Message
        }
    } else {
        Write-Verbose "Module $moduleName is already installed."
    }

    # Import the module for the current session
    Import-Module -Name $moduleName
}

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
function Convert-Sid2User {
    Param(
        [parameter(Mandatory = $True,
            HelpMessage = "The SID of the user to lookup.",
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false)]
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
    
}

function Convert-ObjectId2User {
    Param(
        [parameter(Mandatory = $true,
            HelpMessage = "The (Entra) object ID of the user to lookup.",
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false)]
         [string] $ObjectId
    )

        # a7d8bc73-121d-4355-bab4-8cbf34530232
    if ($ObjectId -match "[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}") {
        if (-not (Test-HasMgContext)) {
            Connect-MgGraph -Scopes 'User.Read.All','GroupMember.Read.All','Group.Read.All' -NoWelcome
        }
        $User = Get-MgUser -UserId $ObjectId | Select-Object UserPrincipalName, DisplayName, Surname, GivenName
        $User
    } else {
        $errorObj = New-Object System.FormatException("ObjectID ($ObjectId) not recognized as a user object ID.")
        Throw $errorObj
    }
}

# If using Windows Powershell (5.1), increase the maximum function count to avoid "Too many functions defined" errors.
# This is not needed in Powershell 7.x and later.
# This should also really be in the powershell profile, but adding here for completeness.
#$MaximumFunctionCount = 32768

# Check if the required module(s) are installed.  Install them if they are not present.
Write-Verbose "Checking if the required module(s) are already installed."
Write-Verbose "They will be installed, if they are not currently."
Install-ModuleIfNotInstalled -moduleName Microsoft.Graph

# Connect to Entra ID via the Graph API.  This may popup an authentication prompt if it's the first time.
Connect-MgGraph -Scopes 'GroupMember.Read.All', 'Group.Read.All' -NoWelcome

$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"
$Members = Get-MgGroupMember -GroupId $Group.Id -All
foreach ($member in $Members) {
    # $member
    $user = Convert-ObjectId2User -ObjectId $member.Id
    $user
}