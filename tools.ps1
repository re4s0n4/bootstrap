function Test-RestartPending {
    [CmdletBinding()]
    param ()

    $restartPending = $false

    # Check Windows Update Restart Pending
    $windowsUpdateKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
    if (Test-Path $windowsUpdateKey) {
        $wuRebootRequired = Get-ItemProperty -Path $windowsUpdateKey -Name RebootRequired -ErrorAction SilentlyContinue
        if ($wuRebootRequired) { $restartPending = $true }
    }

    # Check Component-Based Servicing (CBS) Restart Pending
    $cbsKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    if (Test-Path $cbsKey) { $restartPending = $true }

    # Check PendingFileRenameOperations
    $pendingFileRenameKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    if (Test-Path $pendingFileRenameKey) {
        $pendingFileRename = Get-ItemProperty -Path $pendingFileRenameKey -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
        if ($pendingFileRename) { $restartPending = $true }
    }

    # Check if a domain join requires a restart
    $domainJoinKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon'
    if (Test-Path $domainJoinKey) {
        $joinStatus = Get-ItemProperty -Path $domainJoinKey -Name JoinDomain -ErrorAction SilentlyContinue
        if ($joinStatus) { $restartPending = $true }
    }

    return $restartPending
}

# Example Usage:
if (Test-RestartPending) {
    Write-Output "A restart is pending."
} else {
    Write-Output "No restart is required."
}
