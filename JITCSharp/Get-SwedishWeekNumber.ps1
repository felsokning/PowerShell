$AssemblyPath = "<Path to the DLL built from Cpp (Public.Cpp.Research.dll)"

$Source = @"
            namespace Test
            {
                using System;
                using System.Collections.Generic;
                using System.Linq;
                using System.Net;
                using System.Runtime.InteropServices;

                public static class Svenska
                {
                    [DllImport(@"$($AssemblyPath)")]
                    public static extern UIntPtr VeckanEntry();

                    public static uint GetWeekNumber()
                    {
                        try
                        {
                            UIntPtr returnIntPtr = UIntPtr.Zero;
                            returnIntPtr = VeckanEntry();
                            if(returnIntPtr != null && returnIntPtr != UIntPtr.Zero)
                            {
                                uint returnInt = returnIntPtr.ToUInt32();
                                return returnInt;
                            }
                            else
                            {
                                return 1000;
                            }
                        }
                        catch(ExternalException e)
                        {
                            throw new Exception(string.Format("Exception: {0}", e.ErrorCode));
                        }
                    }
                }
            }
"@

Add-Type -TypeDefinition $Source -Language CSharp -ReferencedAssemblies System.Runtime

return [Test.Svenska]::GetWeekNumber()