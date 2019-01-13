param(
        [Parameter(ParameterSetName='InitialState')]
        [Switch]$SetInitialState,
        [Parameter(ParameterSetName='Dump')]
        [Switch]$DumpProcess,
        [Parameter(ParameterSetName='Dump')]
        [int]$ProcessId = 0,
        [Parameter(ParameterSetName='Dump')]
        [int]$NumberOfDumps = 0,
        [Parameter(ParameterSetName='Dump')]
        [int]$DelayInSeconds = 0,
        [Parameter(ParameterSetName='CopyDumps')]
        [Switch]$CopyDumpsOut,
        [Parameter(ParameterSetName='CopyDumps')]
        [string]$TargetPath = [string]::Empty
        )

# We plan for the condition that someone tries on Linux.        
if($IsLinux)
{
    ThrowError -ExceptionName InvalidOperationException -errorId NotSupportedOnLinux -errorCategory InvalidOperation -ExceptionMessage "There is, currently, no plans to support Linux. Yet..."
}

# Since the Public Directories are accessible to everyone, we place the file in the Public Downloads folder.
# To do so, we obtain the version of the kernel in the Operating System.
[int]$OS_Version_Major = [Environment]::OSVersion.Version.Major
$User = "Public"
if($OS_Version_Major -ge 6)
{
	$localDir = "C:\Users\" + $User + "\Downloads" #We create a string-path to use for placing the file
}
elseif($OS_Version_Major -eq 5)
{
    $localDir = "C:\Documents and Settings\" + $User + "\Downloads"
}
else
{
    Write-Warning -Message "You are running this script on a non-supported version of Microsoft Windows."
    break
}

$LogFilePath = "$($localDir)\Dumps\ProcessDumpLogs.txt"

function SetInitialState
{
    $CdbPath = "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe"
    $TP = Test-Path $CdbPath
    if($TP.Equals($True))
    {
        Write-Host -ForegroundColor Green "CDB was found on the system. Continuing..."
        if(-not (Test-Path "$($localDir)\Dumps\"))
        {
            Write-Host -ForegroundColor Green "Created the Dumps subfolder..."
            mkdir "$($localDir)\Dumps\" | Out-Null
        }
        if(-not (Test-Path $LogFilePath))
        {
            # We create the log-file to write to.
            Write-Host "Creating log file at $($LogFilePath)"
            #We use the old IO method to create the logfile.
            $objLogs = [System.IO.File]::Create($LogFilePath)
            #We dispose of the object, once created; otherwise, the file remains locked/in use.
            $objLogs.Close()
        }
    }
    else
    {
        Write-Warning -Message "CDB was NOT found on the system. Downloading the Windows 10 SDK for unattended install..."
        if(-not (Test-Path "$($localDir)\Dumps\"))
        {
            mkdir "$($localDir)\Dumps\"
        }
        if(-not (Test-Path "$($localDir)\Dumps\ProcessDumpLogs.txt"))
        {
            # We create the log-file to write to.
            Write-Host "Creating log file at $($localDir)\Dumps\ProcessDumpLogs.txt"
            #We use the old IO method to create the logfile.
            $objLogs = [System.IO.File]::Create("$($localDir)\Dumps\ProcessDumpLogs.txt")
            #We dispose of the object, once created; otherwise, the file remains locked/in use.
            $objLogs.Close()
        }
        if(-not (Test-Path "$($localDir)\win10sdksetup.exe"))
        {
            # Download the Windows 10 SDK Installer
            Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkID=2033908" -OutFile "$($localDir)\win10sdksetup.exe"
        }    

        # Install the Debugging tools, opting out of the Customer Experience Improvement Program - as default - due to GDPR
        powershell "$($localDir)\win10sdksetup.exe /features 'OptionId.WindowsDesktopDebuggers' /ceip 'off'"
    }
}

function CreateDumpFiles
{
    if(-not (Test-Path "$($localDir)\Dumps\ProcessDumpLogs.txt"))
    {
        # We create the log-file to write to.
        Write-Host "Creating log file at $($localDir)\Dumps\ProcessDumpLogs.txt"
        #We use the old IO method to create the logfile.
        $objLogs = [System.IO.File]::Create("$($localDir)\Dumps\ProcessDumpLogs.txt")
        #We dispose of the object, once created; otherwise, the file remains locked/in use.
        $objLogs.Close()
    }

    # Create the stream writer, to write to the log.
    $streamWriter = [System.IO.StreamWriter]::new($LogFilePath)
    $streamWriter.WriteLine("Script was called at $([System.DateTime]::UtcNow.ToString())")
    $streamWriter.NewLine | Out-Null
    $streamWriter.Flush() | Out-Null

    # Parameter validation happens on the .ctor(), so we don't worry about that here.
    if($host.Version.Major -ge 3)
    {
        #We use .NET to get the system's name
        $compName = [System.Net.DNS]::GetHostEntry("localhost").HostName.ToString()
        #We use .NET to collect the names of processes running in the system
        $process = [System.Diagnostics.Process]::GetProcessById($ProcessId)
	    $objProcID = $process | Select-Object -ExpandProperty ID
	    $objProcName = $process | Select-Object -ExpandProperty ProcessName
        $objProcFV = $process | Select-Object -ExpandProperty FileVersion
        $objProcPV = $process | Select-Object -ExpandProperty ProductVersion
        $streamWriter.WriteLine("Dumping $($objProcName) with $($objProcID), FileVersion: $($objProcFV), ProductVersion: $($objProcPv)")
        $streamWriter.NewLine
        $streamWriter.Flush()
        for ($i = 0; $i -lt $NumberOfDumps ; $i++)
	    {
            #We put the month number to string.
		    $Month = [DateTime]::Now.ToString('MMM')
            #We put the day number to string.
            $Day = [DateTime]::Now.ToString('dd')
            #We put the year to string.
            $Year = [DateTime]::Now.ToString('yyyy')
            #We put the hour number to string.
		    $Hour = [DateTime]::Now.ToString('HH')
            #We put the minute number to string.
            $Minute = [DateTime]::Now.Minute.ToString("00.##")
            #We concatenate these values to a string for the date/time.
            $DateTime = "$Day" + "." + "$Month" + "." + "$Year" + "_" + "$Hour" + "." + "$Minute"
            #We concatenate values to a string for the file name
            $dumpFilename = $DateTime + "_" + $compName + "_" + $objProcName + "_" + $objProcID + ".dmp"
            $streamWriter.WriteLine("Starting mini dump number $($i) of $($objProcName) to $($localDir)\Dumps\$($dumpFileName).mini$($i)")
            $streamWriter.NewLine | Out-Null
            $streamWriter.Flush() | Out-Null
            #We perform a minidump of the process
            [void] (& 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe' -p $objProcID -pv -c ".dump /ma $localDir\Dumps\$dumpFilename.mini$i;q")
            if($i -lt ($NumberOfDumps -1))
            {
            	$streamWriter.WriteLine("Sleeping $($DelayInSeconds) seconds.")
                $streamWriter.NewLine | Out-Null
                Start-Sleep -Seconds $DelayInSeconds
            }
	    }
    }
    else
    {
        Write-Error -Message "This script is only valid for versions of PowerShell 3 or greater."
        $streamWriter.WriteLine("Invalid PowerShell version found...")
    }

    $streamWriter.Close()
    $streamWriter.Dispose()
}

function ExportDumpFiles
{
    if(-not [string]::IsNullOrWhiteSpace($TargetPath))
    {
        (robocopy "$($localDir)\Dumps\" $TargetPath *.* /MIR) | Out-Null
    }
    else 
    {
        throw [System.Exception]::new("TargetPath cannot be empty")
    }
}

if($SetInitialState)
{
    SetInitialState
    break
}

if($DumpProcess)
{
    CreateDumpFiles
}

if($CopyDumpsOut)
{
    ExportDumpFiles
}