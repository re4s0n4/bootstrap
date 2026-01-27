Reset-RDPCertificate {

    <#
    .SYNOPSIS
    Checks the Local Machine "Remote Desktop" store for the valid certificate with the longest lifespan 
    and binds it to the RDP-Tcp listener if it is not already set.
    #>

    # --- Configuration ---
    $CertStorePath = 'Cert:\LocalMachine\Remote Desktop\'
    $RdpRegPath    = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

    # --- Step 1: Find the Best Candidate Certificate ---
    # We filter for unexpired certs and pick the one with the longest remaining life
    $TargetCert = Get-ChildItem -Path $CertStorePath -ErrorAction SilentlyContinue | 
                Where-Object { $_.NotAfter -gt (Get-Date) } | 
                Sort-Object NotAfter -Descending | 
                Select-Object -First 1

    # VALIDATION 1: Ensure a certificate actually exists before proceeding
    if (-not $TargetCert) {
        Write-Error "STOP: No valid (unexpired) certificates found in $CertStorePath."
        Write-Warning "The script cannot proceed because there is no certificate to apply."
        exit
    }

    # --- Step 2: Get Current Configuration ---
    try {
        $CurrentConf = Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'" -ErrorAction Stop
        $CurrentHash = $CurrentConf.SSLCertificateSHA1Hash
    }
    catch {
        Write-Warning "Could not query active RDP settings via WMI. Assuming configuration is empty or default."
        $CurrentHash = $null
    }

    # --- Step 3: Compare and Apply ---
    # VALIDATION 2: Compare specific strings (and handle nulls) to avoid false positives
    if ($CurrentHash -eq $TargetCert.Thumbprint) {
        Write-Host "✅ Validation Passed: The correct certificate is already active." -ForegroundColor Green
        Write-Host "   Thumbprint: $($TargetCert.Thumbprint)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Mismatch Detected. Updating Configuration..." -ForegroundColor Yellow
        Write-Host "   Current Active: $(if($CurrentHash){$CurrentHash}else{'[Default/None]'})"
        Write-Host "   Target New    : $($TargetCert.Thumbprint)"

        try {
            # Convert Hex String to Byte Array (Registry requires Binary type)
            $Thumbprint = $TargetCert.Thumbprint
            $Bytes = 0..($Thumbprint.Length/2 - 1) | ForEach-Object { [Convert]::ToByte($Thumbprint.Substring($_*2,2),16) }

            # Apply to Registry
            Set-ItemProperty -Path $RdpRegPath -Name "SSLCertificateSHA1Hash" -Value $Bytes -Type Binary -ErrorAction Stop
            
            Write-Host "✅ Registry Updated Successfully." -ForegroundColor Green
            
            # Optional: Trigger Restart
            Write-Warning "The 'Remote Desktop Services' service must be restarted for this to take effect."
            Restart-Service "TermService" -Force -Confirm:$false
        }
        catch {
            Write-Error "FAILED to update registry. Ensure you are running as Administrator."
            Write-Error $_.Exception.Message
        }
    }
}