# Define a function named Invoke-RemoteScript
Function Invoke-RemoteScript {
    [CmdletBinding()]
    param(
        # Define a parameter named 'address' which is a string and is the first positional parameter
        [Parameter(Position = 0)]
        [string]$address,
        # Define a parameter to capture remaining arguments passed to the function
        [Parameter(ValueFromRemainingArguments = $true)]
        $remainingArgs
    )

    # Use Invoke-Expression (iex) to execute the script downloaded from the provided address with remaining arguments
    iex "& { $(irm $address) } $remainingArgs"
}

# Create an alias 'irs' for the Invoke-RemoteScript function
Set-Alias -Name irs -Value Invoke-RemoteScript

# Use the alias 'irs' to invoke a remote script from the given URL with the argument '-daily'
irs 'https://aka.ms/install-powershell.ps1' -daily

# Download a script from the given URL and save it to a temporary file
irm 'https://raw.githubusercontent.com/Kamdzy/Windows-Terminal/master/bootstrap/pwsh-core.ps1' `
    -OutFile $env:TEMP\pwsh-core.ps1

# Define the path to the PowerShell executable
$pwsh = "$env:LOCALAPPDATA\Microsoft\powershell-daily\pwsh.exe"

# Execute the downloaded script using the PowerShell executable
. $pwsh -nologo -noprofile -file $env:TEMP\pwsh-core.ps1