# 1.0.8398.17892 - Version number or identifier

# Define a function named Update-PoshTheme to update the Oh My Posh theme
Function Update-PoshTheme {

  # URL of the Oh My Posh theme JSON file
  $address = "https://raw.githubusercontent.com/Kamdzy/Windows-Terminal/master/configs/.poshthemes/oh-my-posh.json"
  # Path to the .poshthemes directory
  $ROOT = "~/.poshthemes/"

  # Create the .poshthemes directory if it does not exist
  New-Item -Path $ROOT -ItemType Directory -EA SilentlyContinue | Out-Null
  # Download the Oh My Posh theme JSON file and save it to the .poshthemes directory
  Invoke-RestMethod -Uri $address -OutFile "$($ROOT)oh-my-posh.json"
}

# Define a function named Upgrade-TerminalIcons to install or update the Terminal-Icons module
Function Upgrade-TerminalIcons {

  # If the Terminal-Icons module is already installed, update it
  if (Get-Module Terminal-Icons -ListAvailable) { Update-Module Terminal-Icons -Force }
  # Otherwise, install the Terminal-Icons module
  else { Install-Module Terminal-Icons -Force }
}

# Oh My Posh should be installed using WinGet on Windows
# . winget install JanDeDobbeleer.OhMyPosh -s winget
# Use the following link for bootstrap:
# https://github.com/Kamdzy/Windows-Terminal/blob/master/bootstrap/pwsh-core.ps1#L101-L106 

# Oh My Posh should be installed using Homebrew or manually on Linux
# See instructions at:
# https://ohmyposh.dev/docs/installation/linux

# Initialize Oh My Posh with the specified configuration file and execute the resulting command
. oh-my-posh init pwsh --config "~/.poshthemes/oh-my-posh.json" | Invoke-Expression


# Check if the Terminal-Icons module is not available
if (-not (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Terminal-Icons" })) {
  Write-Host "Terminal-Icons module not found. Installing..." -ForegroundColor Yellow

  # If not available, install the Terminal-Icons module
  Install-Module Terminal-Icons -Force
}

Import-Module -Name Terminal-Icons
