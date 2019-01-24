param(
        [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
        [Uri]$Url)

$webRequest = [net.Webrequest]::Create($Url)
$webRequest.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$webRequest.GetResponse()
