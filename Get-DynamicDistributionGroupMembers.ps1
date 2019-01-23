<#
.SYNOPSIS
	Finds the members that should belong to a dynamic distribution group.

.DESCRIPTION
	Leverages the commands found in Exchange Management Shell (EMS) to find
	the recipients that should belong to a dynamic distribution group.

.NOTES
    Author         : felsokning
    Prerequisite   : Exchange Management Shell (EMS)
    Copyright 2019 - felsokning

.LINK

.EXAMPLE
    ./Get-DynamicDistributionGroupMembers.ps1
#>

﻿param(
            [Parameter(Position=0,Mandatory=$true)]
            [string]$Identity)

$DDG = Get-DynamicDistributionGroup $Identity
$Global:DDGMembers = Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter
