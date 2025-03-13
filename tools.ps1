# Define the GitHub repository and the asset you want to download
$repoOwner = "re4s0n4"
$repoName = "bootstrap"
$assets = "sources"

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
        DownloadURL  = "https://raw.githubusercontent.com/re4s0n4/bootstrap/main/$($assets)/$($file.name)"
    }

    # Add the file object to the array
    $fileArray += $fileObject
}

# Initialize a variable to hold all file contents
$allContents = ""

# Loop through each file in the list
foreach ($file in $fileArray) {
    # Download the raw content from the file's URL
    $content = Invoke-RestMethod -Uri $file.DownloadURL -Headers @{ "User-Agent" = "PowerShell" }

    # Append the content to the $allContents variable
    $allContents += "`n" + $content
}

Invoke-Expression $allContents