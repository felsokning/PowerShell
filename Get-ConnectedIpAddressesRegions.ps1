<#
.SYNOPSIS
	Attempts to find the IP addresses that the machine is connected to. Then uses geoiplookup
	to find the geographic location of each IP address that we're connected to.
.DESCRIPTION
    Attempts to find the IP addresses that the machine is connected to. Then uses geoiplookup
	to find the geographic location of each IP address that we're connected to.
.NOTES
    Author         : felsokning
    Prerequisite   : Linux and geoiplookup (https://linux.die.net/man/1/geoiplookup)
    Copyright 2019 - felsokning
.LINK
.EXAMPLE
    ./Get-ConnectedIpAddressesRegions.ps1
#>

if($IsLinux)
{
	$ips = sudo netstat -antp "2>/dev/null" | grep "tcp" | awk '{print $5}'| cut -d: -f1
	$deDuplicatedIps = $ips | Select-Object -Unique
	foreach($i in $deDuplicatedIps)
	{
		if(-not [string]::IsNullOrWhiteSpace($i) -and $i -ne "0.0.0.0")
		{
			$data = geoiplookup $i
			$splitData = $data.Split(":")
			$country = $splitData[1]
			Write-Host "$($i) $($country)"
		}
	}
}
if(-not $IsLinux)
{
	Write-Error -Message "This script was written for PowerShell on *nix. Please run in an appropriate environment."
}