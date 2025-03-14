function Test-Port {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$NetworkPrefix = "10.159.97",
        [Parameter(Mandatory = $false)]
        [switch]$ShowOpenOnly,
        [Parameter(Mandatory = $false)]
        [int[]]$Ports = @(80, 443),
        [Parameter(Mandatory = $false)]
        [int]$Timeout = 500,
        [Parmeter(Mandatory = $false)]
        [int] $threads = 10
    )

    begin {
        $ipRange = 0..254 | ForEach-Object { "$NetworkPrefix.$_" }
    }

    process {
        # Determine if input is a single IP or network prefix
        if ($NetworkPrefix -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
            $ipRange = @($NetworkPrefix)
            # If single IP and no specific ports, scan all ports
            if ($Ports.Count -eq 2 -and $Ports[0] -eq 80 -and $Ports[1] -eq 443) {
            $Ports = 1..65535
            }
        } else {
            $ipRange = 0..254 | ForEach-Object { "$NetworkPrefix.$_" }
        }

        foreach ($ip in $ipRange) {
            foreach ($port in $Ports) {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            try {
                Write-Verbose "Testing connection to $ip on port $port"
                $connect = $tcpClient.BeginConnect($ip, $port, $null, $null)
                $success = $connect.AsyncWaitHandle.WaitOne($Timeout, $true)

                if ($success -and $tcpClient.Connected) {
                Write-Output "Port $port is open on $ip"
                } elseif (-not $ShowOpenOnly) {
                Write-Output "Port $port is not open on $ip"
                }
            } catch {
                Write-Warning "Error connecting to port $port on ${ip}: $_"
            } finally {
                $tcpClient.Close()
            }
            }
        }
    }
}