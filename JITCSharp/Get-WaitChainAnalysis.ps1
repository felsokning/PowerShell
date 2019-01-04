
param($Process)

$AssemblyPath = "<path to the C++ DLL you built from Cpp\UnmanagedDebugging>"
$Source = @"
    namespace Testing
    {
        using System;
        using System.Runtime.InteropServices;

        public static class Debug
        {
            [DllImport($($AssemblyPath))]
            public static extern IntPtr ExternalEntry(int id);

            public static string GetThreadWaitChain(int id)
            {
                IntPtr returnIntPtr = IntPtr.Zero;
                returnIntPtr = ExternalEntry(id);
                if(returnIntPtr != null && returnIntPtr != IntPtr.Zero)
                {
                    return Marshal.PtrToStringUni(returnIntPtr);
                }
                else
                {
                    return "Something is not working";
                }
            }
        }
    }
"@

Add-Type -TypeDefinition $Source -Language CSharp -ReferencedAssemblies System.Runtime

# TODO: IIS Instances via the API for finding the Instance's Name to PID translation.

# First, we check that the parameter we were given is an int, if not, proceed as a string
[int]$targetInt = 0
if([int]::TryParse($Process, [ref]$targetInt))
{
    return [Testing.Debug]::GetThreadWaitChain($Process)
}
else
{
    $processOBj = [System.Diagnostics.Process]::GetProcessesByName($Process)
    if($processOBj.Count -gt 0)
    {
        $sb = @()
        foreach($po in $processOBj)
        {
            $sb += [Testing.Debug]::GetThreadWaitChain($po.Id)
        }
        return $sb
    }
    else
    {
        return "No process can be found with the name given :$($Process)"
    }
}