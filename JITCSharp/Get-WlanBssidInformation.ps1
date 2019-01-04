$AssemblyPath = "<Path Where You Built the WlanObtainBssids DLL>"

$Source = @"
            namespace Test
            {
                using System;
                using System.Collections.Generic;
                using System.Linq;
                using System.Net;
                using System.Runtime.InteropServices;

                public static class Debug
                {
                    [DllImport(@"$($AssemblyPath)")]
                    public static extern IntPtr Entry();

                    public static List<string> NetworkList = new List<string>(0);

                    public static string[] GetWirelessLanData()
                    {
                        try
                        {
                            IntPtr returnIntPtr = IntPtr.Zero;
                            returnIntPtr = Entry();
                            List<string> newStrings = new List<string>(0);
                            if(returnIntPtr != null && returnIntPtr != IntPtr.Zero)
                            {
                                string returnedIntPtrUniString = Marshal.PtrToStringUni(returnIntPtr);
                                string returnedTrimmedIntPtrUniString = returnedIntPtrUniString.Trim();
                                string[] returnedUniStrings = returnedTrimmedIntPtrUniString.Split(';');
                                if(NetworkList.Count == 0)
                                {

                                    NetworkList = returnedUniStrings.ToList();
                                    return NetworkList.ToArray();
                                }
                                else
                                {
                                    returnedUniStrings.ToList().ForEach(x => 
                                    {
                                        if(!NetworkList.Contains(x))
                                        {
                                            newStrings.Add(x);
                                            NetworkList.Add(x);
                                        }
                                    });

                                    return newStrings.ToArray();
                                }
                            }
                            else
                            {
                                return new string[0];
                            }
                        }
                        catch(ExternalException e)
                        {
                            throw new Exception(string.Format("Exception: {0}", e.ErrorCode));
                        }
                    }

                    public static string ReturnMacAddress(string listString)
                    {
                        string[] splitStrings = listString.Split(' ');
                        return splitStrings[0];
                    }
                }
            }
"@

Add-Type -TypeDefinition $Source -Language CSharp -ReferencedAssemblies System.Runtime

while($true)
{
    $strings = @();
    $strings = [Test.Debug]::GetWirelessLanData();
    if(-not $strings.Count -eq 0)
    {
        $strings
    };

    # Sleep for 1 second before next iteration to prevent thrashing.
    Start-Sleep -Seconds 1
}