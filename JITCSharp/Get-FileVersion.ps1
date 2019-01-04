param ([string]$FilePath)

$Source = @"
            namespace Public.PowerShell.Utilities
            {
                using System.Diagnostics;

                /// <summary>
                ///     Intializes a new instance of the <see cref="FileVersioning"> class.
                /// </summary>
                public static class FileVersioning
                {
                    /// <summary>
                    ///     Uses .NET to obtain the file version of the specified assembly.
                    /// </summary>
                    /// <param name="filePath">The path to the assembly.</param>
                    /// <returns>A string representing the file's raw version.</returns>
                    public static string GetFileVersion(string filePath)
                    {
                        return FileVersionInfo.GetVersionInfo(filePath).FileVersion.ToString();
                    }
                }
            }
"@

Add-Type -TypeDefinition $Source -Language CSharp 

# Check if we were given a bad file path, if so just throw now.
if(-not ([Regex]::Match($FilePath, "^[ -~]:\\") -or [Regex]::Match($FilePath, "^\\\\")) -xor -not (Test-Path $FilePath))
{
    throw [System.IO.FileNotFoundException]::new("A valid file path must be given.");
}

return [Public.PowerShell.Utilities.FileVersioning]::GetFileVersion($FilePath)
