# Define the GitHub repository and the asset you want to download
$repoOwner = "re4s0n4"
$repoName = "bootstrap"
$assets = "/sources"
$assetName = "tools.ps1"

# Fetch the latest release information from the GitHub API
$githubApiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
$response = Invoke-RestMethod -Uri $githubApiUrl -Headers @{ "User-Agent" = "PowerShell" }

# Find the asset download URL for tools.ps1
$downloadUrl = $response.assets | Where-Object { $_.name -eq $assetName } | Select-Object -ExpandProperty browser_download_url

# Check if the asset URL is found
if ($downloadUrl) {
    Write-Host "Found $assetName at: $downloadUrl"
    
    # Download the file contents directly and pass them to the pipeline
    $toolsContent = Invoke-WebRequest -Uri $downloadUrl

    # Output the content to the pipeline
    $toolsContent.Content | Invoke-Expression
    Write-Host "$assetName has been executed successfully!"
} else {
    Write-Host "Error: Could not find the asset '$assetName' in the latest release."
}
