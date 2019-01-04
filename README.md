# PowerShell
This repo contains PowerShell scripts Id've written over time to accomplish tasks.

## Resolve-NetworkNeighbors.ps1
This script attempts to ping all hosts in the last octet (e.g.: 10.0.0.x) and, upon a response, later tries to resolve the IP addresses to hostnames in DNS.

## JITCSharp
This folder contains PowerShell scripts that include C# source, which PowerShell JIT's into a type, when invoked by the "Add-Type" command. It's important to not that the type is only available within the app domain and once the PowerShell instance is closed, that type is disposed of via GC.

### Get-FileVersion.ps1
This script attempts to find the version of the DLL or executable given by the user in the parameter passed at instantiation.

### Get-WaitChainAnalysis.ps1
This script leverages InterOpServices to load a C++ DLL (see: Cpp\UnmanagedDebugging\) and call into it's main entry point. The C++ DLL leverages the [Wait-Chain Traversal API](https://docs.microsoft.com/en-us/windows/desktop/Debug/wait-chain-traversal) to analyze the wait-chains of all of the threads owned by the process specified by the user in the passed parameter.

### Get-WlanBssidInformation.ps1
This script leverages InteropServices to load a C++ DLL (see: Cpp\WlanObtainBssids) and call into it's main entry point. The C++ DLL leverages the WlanGetNetworkBssList method in Windows API to return the list of BSSIDs and associated network SSIDs that are available to the wireless interface.

