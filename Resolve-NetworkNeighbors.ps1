function Resolve-NetworkNeighbours
{
    <#
        .SYNOPSIS
        Use this script to find all hosts up in a specific octet.

        .DESCRIPTION
        This script uses .NET to ping a host to see if it's alive and then attempts to resolve it to a hostname via DNS.

        .PARAMETER Prefix
        The first three octets of an IP Address range to target.

        .INPUTS
        None. You cannot pipe objects to Resolve-NetworkNeighbours.

        .OUTPUTS
        Array[PSCustomObject]. Resolve-NetworkNeighbours returns a string for each host found up.

        .EXAMPLE
        Resolve-NetworkNeighbours

        .EXAMPLE
        Resolve-NetworkNeighbours -Prefix 127.0.0.

        .EXAMPLE
        Resolve-NetworkNeighbours -Prefix 169.154.125

        .LINK
    #>

    param([string]$Prefix)

    # If we weren't given the param, assume we're looking from the local machine.
    if ([string]::IsNullOrWhiteSpace($Prefix)) 
    {
        $addressString = (([System.Net.Dns]::GetHostByName([System.Net.Dns]::GetHostName())).AddressList[0]).IPAddressToString
        $addressStrings = $addressString.Split(".")
        $Prefix = $addressStrings[0] + "." + $addressStrings[1] + "." + $addressStrings[2] + "."
    }

    # Check the parameter we were given and immediately fail if it's bad.
    if(-not [Regex]::Match($Prefix, "^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])").Success)
    {
        throw [Exception]::new("Prefix must be a valid IP range and the first three octets. (e.g.: 127.0.0.)")
    }
    
    # Check if we were given a trailing period mark; otherwise, supply our own.
    if(-not $Prefix.EndsWith("."))
    {
        $Prefix = $Prefix + "."
    }

    $collObj = @()
    $suffixes = 0..255
    [int]$timeOut = 120
    $pingOptions = [System.Net.NetworkInformation.PingOptions]::new($timeOut, $true)
    $buffer = [System.Text.Encoding]::Unicode.GetBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    foreach($suffix in $suffixes)
    {
        $address = [System.Net.IPAddress]::Parse($Prefix + $suffix)
        $pinger = [System.Net.NetworkInformation.Ping]::new()
        try 
        {
            $reply = $pinger.Send($address,$timeOut,$buffer,$pingOptions)
            if($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
            {
                $obj = New-Object -TypeName PSObject
                $hostName = [string]::Empty
                try
                {
                    $hostName = [System.Net.Dns]::GetHostEntry($reply.Address)
                }
                catch
                {
                    # Do nothing, we expect /some/ DNS failures.
                }
                if($hostName -ne [string]::Empty)
                {
                    $obj | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $hostName.Hostname
                    $obj | Add-Member -MemberType NoteProperty -Name "IP Address" -Value $reply.Address
                }
                else
                {
                    $obj | Add-Member -MemberType NoteProperty -Name "Hostname" -Value "<None>"
                    $obj | Add-Member -MemberType NoteProperty -Name "IP Address" -Value $reply.Address
                }
    
                $collObj += $obj
            }
        }
        catch 
        {
            # We expect ping exceptions for invalid IPv4 networks. Let's check if the host thinks that the network is available.
            if(-not [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable())
            {
                throw [Exception]::new("The host has no valid network connectivity with which to test with.")
            }
        }

        # Always dispose, for SCIENCE!
        $pinger.Dispose()
    }

    # Dispose of the things.
    $timeOut = $null
    if(-not $buffer.IsReadOnly)
    {
        $buffer.Clear()
    }
    if(-not $suffixes.IsReadOnly)
    {
        $suffixes.Clear()
    }

    # Return results back to the caller.
    return $collObj
}