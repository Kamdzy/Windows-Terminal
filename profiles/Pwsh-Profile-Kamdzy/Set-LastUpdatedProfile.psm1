Function Set-LastUpdatedProfile {
    [CmdletBinding()]
    param(
        # The name of the profile to update
        [string]$name = "", 
        
        # The date and time to set as the last updated time, defaults to the current UTC time
        [DateTime]$dateTime = [DateTime]::UtcNow 
    )
    
    # Get the path to the cached profile update file based on the profile name
    $cachedProfileUpdateFile = Get-CachedProfileUpdatePath -Name $name
    
    # Format the date and time as a string in the ISO 8601 format
    $timestamp = $dateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    
    # Write the timestamp to the cached profile update file
    Set-Content `
        -Path $cachedProfileUpdateFile `
        -Value $timestamp
}