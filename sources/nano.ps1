function nano ($File) {

    if (!($File -match '\\')) {
        #Combine File with current directory if it's just a file
        $File = Join-Path -Path $PWD -ChildPath $File
    }

    #Set Last Index to find the directory portion of the string
    $lastBackslashIndex = $File.LastIndexOf("\")

    #Create Realitive Path Variable
    $realitivePath = $File.Substring(0, $lastBackslashIndex)

    #Create Filename Variable
    $filename = $File.Substring($lastBackslashIndex + 1)

    #Create Directory Absolute path from Realtive Path Variable
    $absolutePath = (get-item $realitivePath).FullName

    #Rejoin the filename and the absolute path
    $File = Join-Path -Path $absolutePath -ChildPath $filename

    #change slashed to be linux-y
    $File = $File -replace '\\', '/'

    # Extract the drive letter (e.g., 'C:')
    $DriveLetter = $File -replace '^([A-Z]):.*', '$1'

    #Make it lower because wsd is that way
    $DriveLetter = $DriveLetter.ToLower()

    # Remove the drive letter from the path
    $File = $File -replace '^[A-Z]:', ''

    # Prepend the correct WSL mount point based on the drive letter
    $File = "/mnt/$DriveLetter$File"

    #wrap now File string in single quotes
    $File = "`'$File`'"

    # Invoke nano using WSL
    bash -c "nano $File"
}