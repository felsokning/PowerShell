# PowerShell
This repo contains PowerShell scripts Id've written over time to accomplish tasks.

## Get-ConnectedIpAddressesRegions.ps1
(Linux.) Finds the IP addresses that machine is connected to and then attempts to find the geo-location information of the IP address via [geoiplookup](https://linux.die.net/man/1/geoiplookup).

## Get-ProcessDumps.ps1
(Windows.) Allows the user to pre-stage [CDB](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debuggers-in-the-debugging-tools-for-windows-package) on the system via the [Windows 10 SDK](https://developer.microsoft.com/en-US/windows/downloads/windows-10-sdk), take process dumps, and copy the dumps from one location to another via [robocopy](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy). If the process is managed code, you can validate the dump file[s] (before copying them off of the server) vua the [Debug-DumpFile](https://github.com/felsokning/CSharp/blob/master/Public.CSharp.Research/Public.Debugging.Research/DebugDumpFile.cs) command.

## Get-UsernameFromSid.ps1
(Windows + Linux) This script attempts to resolve the given SID to a username.

## Get-WebResponse.ps1
(Windows + Linux) This script attempts make a web request to the given URL and returns the web response from the request made.

## Resolve-NetworkNeighbors.ps1
(Windows + Linux) This script attempts to ping all hosts in the last octet (e.g.: 10.0.0.x) and, upon a response, later tries to resolve the IP addresses to hostnames in DNS.

## Test-TcpConnectivity.ps1
(Windows + Linux) This script attempts to make a TCP connection on the given host and port and returns a boolean determining whether that connection attempt was successful.

## JITCSharp (Currently, Just Windows)
This folder contains PowerShell scripts that include C# source, which PowerShell JIT's into a type, when invoked by the "Add-Type" command. It's important to not that the type is only available within the app domain and once the PowerShell instance is closed, that type is disposed of via GC.

### Get-FileVersion.ps1
This script attempts to find the version of the DLL or executable given by the user in the parameter passed at instantiation.

### Get-SwedishWeekNumber.ps1
This script leverages InterOpServices to load a C++ DLL (see: Cpp\UnmanagedDebugging\) and call into it's main entry point. The C++ DLL then uses native (std) calls to obtain the date and return the week number to the caller.

### Get-WaitChainAnalysis.ps1
This script leverages InterOpServices to load a C++ DLL (see: Cpp\UnmanagedDebugging\) and call into it's main entry point. The C++ DLL leverages the [Wait-Chain Traversal API](https://docs.microsoft.com/en-us/windows/desktop/Debug/wait-chain-traversal) to analyze the wait-chains of all of the threads owned by the process specified by the user in the passed parameter.

### Get-WlanBssidInformation.ps1
This script leverages InteropServices to load a C++ DLL (see: Cpp\WlanObtainBssids) and call into it's main entry point. The C++ DLL leverages the WlanGetNetworkBssList method in Windows API to return the list of BSSIDs and associated network SSIDs that are available to the wireless interface.

