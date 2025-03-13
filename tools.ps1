# Define the GitHub repository and the asset you want to download
$repoOwner = "re4s0n4"
$repoName = "bootstrap"
$assets = "/sources"
$assetName = "tools.ps1"

# Fetch the latest release information from the GitHub API
# $githubApiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
# $response = Invoke-RestMethod -Uri $githubApiUrl -Headers @{ "User-Agent" = "PowerShell" }

# Send a GET request to the GitHub API to fetch the latest release details
$repoContentsUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/sources"

# Fetch the contents of the 'sources' directory using the GitHub API
$sourceFiles = Invoke-RestMethod -Uri $repoContentsUrl -Headers @{ "User-Agent" = "PowerShell" }

# Initialize an array to store file data
$fileArray = @()


# Loop through each file in the 'sources' folder
foreach ($file in $sourceFiles) {
    # Create a file object with the name and the corresponding download URL
    $fileObject = [PSCustomObject]@{
        FileName     = $file.name
        DownloadURL  = "https://github.com/$repoOwner/$repoName/releases/download/latest/$($file.name)"
    }

    # Add the file object to the array
    $fileArray += $fileObject
}

# Output the array with file names and download URLs
$fileArray










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
