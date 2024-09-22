BEGIN {
    # Define a function to install Nerd Fonts
    Function Install-NerdFonts {

        BEGIN {
            # Set the URL for the Nerd Fonts zip file
            $address = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
            # Set the path for the downloaded zip file
            $archive = "$($Env:TEMP)\CascadiaCode.zip"
            # Set the path for the extracted folder
            $folder = "$($Env:TEMP)\CascadiaCode"

            # Create a Shell.Application COM object
            $shell = New-Object -ComObject Shell.Application
            # Get the system fonts path
            $obj = $shell.Namespace(0x14)
            $systemFontsPath = $obj.Self.Path
        }

        PROCESS {
            # Download the Nerd Fonts zip file
            Invoke-RestMethod `
                -Method Get `
                -Uri $address `
                -OutFile $archive

            # Extract the zip file to the specified folder
            Expand-Archive `
                -Path $archive `
                -DestinationPath $folder `
                -Force
            
            # Iterate through each file in the extracted folder
            Get-ChildItem `
                -Path $folder | ForEach-Object {
                $path = $_.FullName
                $fontName = $_.Name
                
                # Skip LICENSE and README.md files
                if ($fontName -eq "LICENSE" -or $fontName -eq "README.md") {
                    Write-Host "Skipping $($path)." -ForegroundColor Yellow
                    return
                }

                # Set the target path for the font file
                $target = Join-Path -Path $systemFontsPath -ChildPath $fontName
                if (test-path $target) {
                    # If the font already exists, ignore it
                    Write-Host "Ignoring $($path) as it already exists." -ForegroundColor DarkGray
                }
                else {
                    # If the font does not exist, install it
                    Write-Host "Installing $($path)..." -ForegroundColor Cyan
                    $obj.CopyHere($path)
                }
            }
        }

        END {
            # Remove the extracted folder
            Remove-Item `
                -Path $folder `
                -Recurse `
                -Force `
                -EA SilentlyContinue
        }

    }

    # Define a function to download a PowerShell profile
    Function Download-Profile {
        [CmdletBinding()]
        param(
            [Parameter(Position = 0)]
            [string]$name
        )

        # Set the base URL for the profile
        $address = "https://raw.githubusercontent.com/Kamdzy/Windows-Terminal/master/profiles/"
        # Get the current profile file name
        $fileName = Split-Path $profile -Leaf
        if ($name -ne "") { $fileName = $fileName.Replace("profile", "$name-profile") }
        # Set the full URL for the profile
        $uri = "$($address)$($fileName)"
        # Set the destination path for the downloaded profile
        $destination = Join-Path -Path (Split-Path $profile) -ChildPath $fileName

        Write-Host "GET $uri HTTP/1.1" -ForegroundColor DarkGray

        # Create the directory for the profile if it does not exist
        New-Item `
            -Path (Split-Path $profile) `
            -ItemType Directory `
            -EA SilentlyContinue `
        | Out-Null

        # Download the profile file
        Invoke-RestMethod `
            -Method Get `
            -Uri $uri `
            -OutFile $destination

        Write-Host "$destination updated." -ForegroundColor Cyan
    }

    # Define a function to install Oh My Posh using winget
    Function Install-OhMyPosh {
        [CmdletBinding()]
        param()

        . winget install JanDeDobbeleer.OhMyPosh -s winget
    }

    # Define a function to upgrade Oh My Posh using winget
    Function Upgrade-OhMyPosh {
        [CmdletBinding()]
        param()

        . winget update JanDeDobbeleer.OhMyPosh -s winget
    }

}

PROCESS {
    # Download the default PowerShell profile
    Download-Profile
    # Install the Pwsh-Profile module from the PSGallery repository
    Install-Module -Name Pwsh-Profile -Repository PSGallery -Scope CurrentUser -Force

    # Load the current profile
    . $profile

    # Install Nerd Fonts
    Install-NerdFonts
    # Install Oh My Posh
    Install-OhMyPosh
    
    # Install and load the "oh-my-posh" profile
    Install-Profile "oh-my-posh" -Load
    # Install and load the "psreadline" profile
    Install-Profile "psreadline" -Load

    # Update the Posh theme
    Update-PoshTheme
    # Upgrade Oh My Posh
    Upgrade-OhMyPosh
    # Upgrade Terminal Icons
    Upgrade-TerminalIcons
}