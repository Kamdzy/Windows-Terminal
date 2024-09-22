Function Get-CachedPowerShellProfileFolder {
    # Get the temporary folder path from the environment variable
    $tempFolder = $Env:TEMP
    
    # Combine the temporary folder path with "PowerShell_profiles" to get the cached profiles folder path
    $cachedProfilesFolder = [IO.Path]::Combine($tempFolder, "PowerShell_profiles")
    
    # If the cached profiles folder does not exist, create it
    if (-not ([IO.Directory]::Exists($cachedProfilesFolder))) {
        New-Item -Path $cachedProfilesFolder -ItemType Directory | Out-Null
    }
    
    # Return the path to the cached profiles folder
    return $cachedProfilesFolder
}