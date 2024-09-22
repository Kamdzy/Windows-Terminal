# Define a function named jq to run the jq-win64.exe command with the provided arguments
Function jq { & "jq-win64.exe" $args }

# Define a function named Load-Json to load a JSON file and convert it to a PowerShell object
Function Load-Json {
    param(
        # Define a parameter named 'path' which can be provided via pipeline or property name
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath")]
        [string] $path
    )

    # Read the content of the file at the specified path as a single string
    $lines = [String]::Join("`r`n", (Get-Content -Path $path -Raw))
    # Convert the JSON string to a PowerShell object
    $json = ConvertFrom-Json -InputObject $lines
    # Output the PowerShell object
    Write-Output $json
}

# Create an alias 'json' for the Load-Json function
Set-Alias -Name json -Value Load-Json

# Define a function named isjson to check if a file contains valid JSON
Function isjson {
    param(
        # Define a parameter named 'path' which can be provided via pipeline or property name
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath")]
        [string] $path
    )
    try {
        # Try to load the JSON file using the Load-Json function
        $json = Load-Json -Path $path
        # If successful, return true
        return $true
    }
    catch {
        # If an error occurs, output "NOPE" and return false
        Write-Host "NOPE"
        return $false
    }
}