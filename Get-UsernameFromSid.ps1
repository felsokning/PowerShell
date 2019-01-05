    <#
        .SYNOPSIS
        Use this script to resolve an object SID to a user name.

        .DESCRIPTION
        This script uses .NET to resolve the given SID to a name of the NT Account.

        .PARAMETER ObjectSid
        SID of the object which you wish to translate.

        .INPUTS
        None. You cannot pipe objects to Get-UsernameFromSid.ps1

        .OUTPUTS
        A string representing the NT Account that resolves to the SID.

        .EXAMPLE
        Get-UsernameFromSid.ps1 -ObjectSid "S-1-10"

        .LINK
        None
    #>

param([string]$ObjectSid)

$securityIdentifier = New-Object System.Security.Principal.SecurityIdentifier($ObjectSid)
$objectTranslation = $securityIdentifier.Translate([System.Security.Principal.NTAccount])
return $objectTranslation.Value
