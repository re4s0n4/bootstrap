# https://www.ipify.org/
function Get-PublicIP {
    $publicIP = Invoke-RestMethod -Uri https://api64.ipify.org?format=json
    
    return $publicIP.ip
}