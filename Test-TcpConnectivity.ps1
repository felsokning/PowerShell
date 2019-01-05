Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$targetHost,

    [Parameter(Mandatory=$True)]
    [string]$Port
)

$obj = New-Object Net.Sockets.TcpClient $targethost, $port
Write-Host $obj.Connected

#Because not disposing of your connections is bad, m'kay?
$obj.Dispose()
