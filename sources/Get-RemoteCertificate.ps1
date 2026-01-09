function Get-RemoteCertificate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$ComputerName,

        [int]$Port = 443
    )

    process {
        # 1. Sanitize Input (Remove https:// or trailing slashes if present)
        $TargetHost = $ComputerName -replace "^https?://" -replace "/.*$"

        $client = $null
        $sslStream = $null

        try {
            Write-Verbose "Connecting to $TargetHost on port $Port..."

            # 2. Open TCP connection
            $client = New-Object System.Net.Sockets.TcpClient
            $client.Connect($TargetHost, $Port)

            # 3. Wrap in SSL Stream (ignoring validation errors to ensure we get the cert even if expired)
            $stream = $client.GetStream()
            $sslStream = New-Object System.Net.Security.SslStream($stream, $false, { $true })
            
            # 4. Authenticate
            $sslStream.AuthenticateAsClient($TargetHost)

            # 5. Extract Certificate
            $cert = $sslStream.RemoteCertificate

            if ($cert) {
                $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
                $daysLeft = ($cert2.NotAfter - (Get-Date)).Days

                # Return a proper PowerShell Object
                [PSCustomObject]@{
                    ComputerName  = $TargetHost
                    Subject       = $cert2.Subject
                    Issuer        = $cert2.Issuer
                    EffectiveDate = $cert2.NotBefore
                    Expiration    = $cert2.NotAfter
                    DaysRemaining = $daysLeft
                    Thumbprint    = $cert2.Thumbprint
                }
            } else {
                Write-Warning "Handshake completed with $TargetHost, but no remote certificate was found."
            }

        } catch {
            Write-Error "Connection to $TargetHost failed. Details: $_"
        } finally {
            # 6. Cleanup
            if ($sslStream) { $sslStream.Close(); $sslStream.Dispose() }
            if ($client) { $client.Close(); $client.Dispose() }
        }
    }
}
